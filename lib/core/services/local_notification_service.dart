import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _nextId = 0;

  static const String _channelId = 'tsiwa_mahber_default';
  static const String _channelName = 'ጽዋ ማህበር';
  static const String _channelDesc = 'Announcements, chat & reminders';

  static const String _urgentChannelId = 'tsiwa_mahber_urgent';
  static const String _urgentChannelName = 'አስቸኳይ ማሳሰቢያ';
  static const String _urgentChannelDesc = 'Urgent announcements & ring bell';

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Create notification channels
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _urgentChannelId,
          _urgentChannelName,
          description: _urgentChannelDesc,
          importance: Importance.max,
        ),
      );
      // Request notification permission (Android 13+)
      await androidPlugin.requestNotificationsPermission();
    }

    final prefs = await SharedPreferences.getInstance();
    _nextId = prefs.getInt('notif_next_id') ?? 0;

    _initialized = true;
  }

  int _getNextId() {
    _nextId = (_nextId + 1) % 100000;
    SharedPreferences.getInstance().then((p) {
      p.setInt('notif_next_id', _nextId);
    });
    return _nextId;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    bool urgent = false,
  }) async {
    if (!_initialized) await init();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        urgent ? _urgentChannelId : _channelId,
        urgent ? _urgentChannelName : _channelName,
        channelDescription:
            urgent ? _urgentChannelDesc : _channelDesc,
        importance: urgent ? Importance.max : Importance.high,
        priority: urgent ? Priority.max : Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFFFC107),
        enableVibration: true,
        playSound: true,
      ),
    );

    await _plugin.show(_getNextId(), title, body, details);
  }

  Future<void> showAnnouncementNotification({
    required String title,
    required String body,
    bool urgent = false,
  }) async {
    await showNotification(
      title: '📢 $title',
      body: body,
      urgent: urgent,
    );
  }

  Future<void> showChatNotification({
    required String roomName,
    required String senderName,
    required String message,
  }) async {
    await showNotification(
      title: roomName,
      body: '$senderName: $message',
    );
  }

  Future<void> showRingBellNotification({
    required String title,
    required String body,
  }) async {
    await showNotification(
      title: '🔔 $title',
      body: body,
      urgent: true,
    );
  }
}
