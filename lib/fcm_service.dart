import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission to receive notifications
    await _fcm.requestPermission();

    Future<void> sendDeviceTokenToServer(String token) async {
      final Uri url =
          Uri.parse('https://web2apkconvert.onrender.com/store-device-token/');
      final response = await http.post(
        url,
        body: {'token': token},
      );
      if (response.statusCode == 201) {
        print('Device token sent to server successfully');
      } else {
        print('Failed to send device token to server: ${response.statusCode}');
      }
    }

    // On iOS, this helps to get the device token
    String? token = await _fcm.getToken();
    print('Firebase Messaging Token: $token');
    if (token != null) {
      // Send the device token to your server
      await sendDeviceTokenToServer(token);
    } else {
      print('Failed to get device token');
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            'ic_launcher'); // Replace 'app_icon' with your icon name
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      _displayNotification(message);
    });

    // Handle notification taps while app is in foreground/background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Handle notification taps here
      // Access notification data using message.data
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.notification?.title}");
    _displayNotification(message);
  }

  Future<void> _displayNotification(RemoteMessage message) async {
    const String yourChannelId =
        "NR_WEB_CHANNEL_125"; // Replace with your channel ID
    const String yourChannelName = "app_notifications";

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      yourChannelId,
      yourChannelName,
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }
}
