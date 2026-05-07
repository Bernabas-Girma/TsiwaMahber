import 'dart:async';
import 'dart:convert';
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

  /// Global callback for notification taps.
  static void Function(String payload)? onNotificationTap;

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
    final initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && onNotificationTap != null) {
          onNotificationTap!(payload);
        }
      },
    );

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
    String? payload,
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

    await _plugin.show(_getNextId(), title, body, details, payload: payload);
  }

  Future<void> showAnnouncementNotification({
    required String title,
    required String body,
    required String announcementId,
    required String areaId,
    bool urgent = false,
  }) async {
    final payload = jsonEncode({
      'type': 'announcement',
      'announcementId': announcementId,
      'areaId': areaId,
    });
    await showNotification(
      title: title,
      body: body,
      urgent: urgent,
      payload: payload,
    );
  }

  Future<void> showChatNotification({
    required String roomName,
    required String senderName,
    required String message,
    required String roomId,
    required String areaId,
  }) async {
    final payload = jsonEncode({
      'type': 'chat',
      'roomId': roomId,
      'roomName': roomName,
      'areaId': areaId,
    });
    await showNotification(
      title: roomName,
      body: '$senderName: $message',
      payload: payload,
    );
  }

  Future<void> showRingBellNotification({
    required String title,
    required String body,
    String? announcementId,
    String? areaId,
  }) async {
    String? payload;
    if (announcementId != null && areaId != null) {
      payload = jsonEncode({
        'type': 'announcement',
        'announcementId': announcementId,
        'areaId': areaId,
      });
    }
    await showNotification(
      title: title,
      body: body,
      urgent: true,
      payload: payload,
    );
  }
}
