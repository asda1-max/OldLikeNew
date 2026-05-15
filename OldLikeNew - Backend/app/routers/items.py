import os
import uuid
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session
from app.models.item import Item
from app.schemas.item import ItemOut
from app.utils.dependencies import get_db, require_roles
from app.models.user import User

UPLOAD_DIR = os.getenv("UPLOAD_DIR", "uploads")

router = APIRouter(prefix="/items", tags=["items"])


def save_upload(file: UploadFile) -> str:
    ext = os.path.splitext(file.filename or "")[1]
    filename = f"{uuid.uuid4().hex}{ext}"
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    file_path = os.path.join(UPLOAD_DIR, filename)
    with open(file_path, "wb") as f:
        f.write(file.file.read())
    return file_path.replace("\\", "/")


@router.post("/", response_model=ItemOut)
def create_item(
    title: str = Form(...),
    description: str = Form(None),
    category: str = Form(...),
    condition: str = Form(...),
    images: list[UploadFile] = File(default=[]),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("seller")),
):
    image_urls = [save_upload(img) for img in images]
    item = Item(
        seller_id=current_user.id,
        title=title,
        description=description,
        category=category,
        condition=condition,
        image_urls=image_urls,
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.get("/", response_model=list[ItemOut])
def list_my_items(db: Session = Depends(get_db), current_user: User = Depends(require_roles("seller"))):
    return db.query(Item).filter(Item.seller_id == current_user.id).all()


@router.get("/{item_id}", response_model=ItemOut)
def get_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    return item
