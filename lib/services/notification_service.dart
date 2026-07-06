import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Rome'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

   const ios = DarwinInitializationSettings(
  requestAlertPermission: true,
  requestBadgePermission: true,
  requestSoundPermission: true,
  defaultPresentAlert: true,
  defaultPresentBadge: true,
  defaultPresentSound: true,
  defaultPresentBanner: true,
  defaultPresentList: true,
);

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await plugin.initialize(settings);

    await plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> cancelNotification(int id) async {
    await plugin.cancel(id);
  }

  static Future<void> showTestNotification() async {
  try {
    final details = await plugin.getNotificationAppLaunchDetails();

    debugPrint("APP LAUNCH DETAILS: $details");

    await plugin.show(
      9999,
      "TEST",
      "TEST IOS",
      const NotificationDetails(
iOS: DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
  presentBanner: true,
  presentList: true,
),
      ),
    );

    debugPrint("NOTIFICA INVIATA");
  } catch (e) {
    debugPrint("ERRORE NOTIFICA: $e");
  }
}

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final scheduledDate = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        return;
      }

      await plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'barber_channel',
            'Barber Notifications',
            channelDescription: 'Promemoria appuntamenti',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
  presentBanner: true,
  presentList: true,
),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

    } catch (e) {
    }
  }
}