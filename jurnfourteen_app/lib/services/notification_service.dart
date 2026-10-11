import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const String _promptKey = 'notif_prompt_shown';
  static const String _channelId = 'tugas_channel';
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(settings: const InitializationSettings(android: android));
    const channel = AndroidNotificationChannel(
      _channelId,
      'Tugas & Notifikasi',
      description: 'Pemberitahuan tugas baru dan update kehadiran',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _initialized = true;
  }

  static Future<bool> isEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return (await android?.areNotificationsEnabled()) ?? false;
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promptKey, true);
    return granted ?? false;
  }

  static Future<bool> shouldPrompt() async {
    if (await isEnabled()) return false;
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_promptKey) ?? false);
  }

  static Future<void> show(AppNotification n, int id) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Tugas & Notifikasi',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    await _plugin.show(id: id, title: n.title, body: n.body, notificationDetails: details, payload: n.payload);
  }
}
