import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/app.dart';
import 'package:tsiwa_mahber/firebase_options.dart';
import 'package:tsiwa_mahber/core/services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline persistence with unlimited cache for better performance
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize local notifications
  await LocalNotificationService().init();

  runApp(const TsiwaApp());
}
