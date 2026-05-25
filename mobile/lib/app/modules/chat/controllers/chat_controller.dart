import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController extends GetxController {
  final messageController = TextEditingController();
  final isSending = false.obs;
  final userId = RxnInt();
  final userName = 'Pengguna'.obs;

  late final FirebaseFirestore _firestore;

  @override
  void onInit() {
    super.onInit();
    _firestore = FirebaseFirestore.instance;
    _loadProfile();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get messagesStream {
    return _firestore
        .collection('global_chat')
        .doc('room')
        .collection('messages')
        .orderBy('created_at', descending: true)
        .limit(100)
        .snapshots();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId.value = prefs.getInt('auth_user_id');

      final cachedProfile = prefs.getString('profile_cache');
      if (cachedProfile != null && cachedProfile.isNotEmpty) {
        final data = jsonDecode(cachedProfile) as Map<String, dynamic>;
        final name = data['name'] as String?;
        if (name != null && name.isNotEmpty) {
          userName.value = name;
        }
      }
    } catch (e) {
      debugPrint('[Chat] Failed to load profile: $e');
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    isSending.value = true;

    try {
      await _firestore
          .collection('global_chat')
          .doc('room')
          .collection('messages')
          .add({
        'text': text,
        'sender_id': userId.value,
        'sender_name': userName.value,
        'created_at': FieldValue.serverTimestamp(),
        'created_at_local': DateTime.now().toIso8601String(),
      });

      messageController.clear();
      debugPrint('[Chat] Message sent by ${userId.value}');
    } catch (e) {
      debugPrint('[Chat] Failed to send message: $e');
      Get.snackbar('Gagal', 'Pesan tidak terkirim. Coba lagi.');
    } finally {
      isSending.value = false;
    }
  }
}
