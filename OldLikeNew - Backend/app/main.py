import asyncio
import logging
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from app.database import init_db, SessionLocal
from app.routers import auth, users, items, auctions, bids, transactions, chat
from app.services.auction_service import close_expired_auctions

load_dotenv()

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))

UPLOAD_DIR = os.getenv("UPLOAD_DIR", "uploads")
CORS_ALLOW_ORIGINS = os.getenv("CORS_ALLOW_ORIGINS", "*")

app = FastAPI(title="LelangKu API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if CORS_ALLOW_ORIGINS == "*" else CORS_ALLOW_ORIGINS.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(items.router)
app.include_router(auctions.router)
app.include_router(bids.router)
app.include_router(transactions.router)
app.include_router(chat.router)

os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")


async def auction_auto_close_loop(stop_event: asyncio.Event):
    while not stop_event.is_set():
        db = SessionLocal()
        try:
            close_expired_auctions(db)
        finally:
            db.close()
        await asyncio.sleep(30)


@app.on_event("startup")
def on_startup():
    init_db()
    app.state.stop_event = asyncio.Event()
    app.state.bg_task = asyncio.create_task(auction_auto_close_loop(app.state.stop_event))


@app.on_event("shutdown")
def on_shutdown():
    if hasattr(app.state, "stop_event"):
        app.state.stop_event.set()
