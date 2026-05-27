import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';
import '../../../shared/services/auth_service.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: Obx(() {
          final title = controller.chatId.value == null
              ? 'Chat'
              : 'Chat ${_resolvePeerName()}';
          return Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD4A574),
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4A574)),
        elevation: 0,
        leading: Obx(() {
          if (controller.chatId.value == null) {
            return const SizedBox.shrink();
          }
          return IconButton(
            onPressed: controller.closeChat,
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A574)),
          );
        }),
      ),
      body: Obx(() {
        if (controller.chatId.value == null) {
          return _buildChatList();
        }
        return Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoadingMessages.value && controller.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8865A)),
                    ),
                  );
                }

                if (controller.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pesan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final data = controller.messages[index];
                    final senderId = data['sender_id'];
                    final senderName = data['sender_name'] ?? 'Pengguna';
                    final text = data['text'] ?? '';
                    final timeLabel = _formatTime(data);

                    final isMe = senderId != null && senderId == controller.userId.value;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFB8865A) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isMe ? 14 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                senderName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4A2C1A),
                                ),
                              ),
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 14,
                                color: isMe ? Colors.white : const Color(0xFF2C1810),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            _buildComposer(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final authService = Get.find<AuthService>();
        final currentRole = authService.userRole;
        return CustomBottomNavBar(currentIndex: currentRole == 'seller' ? 3 : 2);
      }),
    );
  }

  Widget _buildChatList() {
    return Obx(() {
      if (controller.isLoadingThreads.value && controller.threads.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8865A)),
          ),
        );
      }

      if (controller.threads.isEmpty) {
        return const Center(
          child: Text(
            'Belum ada percakapan',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        itemCount: controller.threads.length,
        itemBuilder: (context, index) {
          final data = controller.threads[index];
          final lastMessage = (data['last_message'] ?? '').toString();
          final lastTime = _formatTime(data);
          final buyerId = data['buyer_id'] as int?;
          final sellerId = data['seller_id'] as int?;
          final buyerName = (data['buyer_name'] ?? 'Pembeli').toString();
          final sellerName = (data['seller_name'] ?? 'Penjual').toString();
          final currentUserId = controller.userId.value;

          String peerLabel = sellerName;
          if (currentUserId != null && currentUserId == sellerId) {
            peerLabel = buyerName;
          }

          return GestureDetector(
            onTap: () => controller.openChatFromThread(data),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFF9F5F0),
                    child: Text(
                      peerLabel.isNotEmpty ? peerLabel[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        color: Color(0xFFB8865A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          peerLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C1810),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastMessage.isEmpty ? 'Mulai chat...' : lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF4A2C1A)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    lastTime,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                filled: true,
                fillColor: const Color(0xFFF9F5F0),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE8DDD3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE8DDD3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFB8865A), width: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() {
            return SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isSending.value ? null : controller.sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8865A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: EdgeInsets.zero,
                ),
                child: controller.isSending.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _resolvePeerName() {
    final currentUserId = controller.userId.value;
    final currentBuyerId = controller.buyerId.value;
    final currentSellerId = controller.sellerId.value;

    if (currentUserId != null && currentUserId == currentSellerId) {
      return controller.buyerName.value;
    }
    if (currentUserId != null && currentUserId == currentBuyerId) {
      return controller.sellerName.value;
    }

    return controller.sellerName.value;
  }

  String _formatTime(Map<String, dynamic> data) {
    final createdAt = data['last_message_at'] ?? data['created_at'];
    DateTime? time;

    if (createdAt is String) {
      time = DateTime.tryParse(createdAt);
    }

    if (time == null) return '';

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
