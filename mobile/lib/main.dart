import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/routes/app_pages.dart';
import 'app/shared/services/auth_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance.requestPermission();
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  await dotenv.load(fileName: ".env");
  final authService = Get.put(AuthService());
  await authService.initSession();
  
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: authService.isLoggedIn ? Routes.HOME : AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
