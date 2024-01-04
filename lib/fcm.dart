import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage? message) async{
  await Firebase.initializeApp();
  print('Handling a background message: ${message?.notification?.title}');

}

class Fcm{

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // foreground 알람을 위해 채널 생성
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'notification_channel_id',
      //'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications',
      importance: Importance.max,
  );

  Future<void> initNotification() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final fcmToken = await messaging.getToken();
    print(fcmToken);
    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await initPush();
  }

  Future<void> initPush() async{
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    //AndroidInitializationSettings initSettingAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    //InitializationSettings initSettings = InitializationSettings(android: initSettingAndroid);
    //flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;


      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                priority: Priority.high,
                channelDescription: channel.description,
                //icon: '@mipmap/ic_launcher',
                icon: '@android:drawable/btn_default_small'
                // other properties...
              ),
            ),
          payload: jsonEncode(message.toMap()),
        );
      }
    });
  }

  // 푸시 메세지 클릭 시 페이지 이동
  void handleMessage(RemoteMessage? message){
    if(message == null) return;

    /* background fcm 알람 클릭 시 페이지 이동
    navigatorKey.currentState?.pushNamed(
      '/notification_screen',
      arguments: message,
    );
    */
  }

  Future<void> showNotification(RemoteMessage message) async{
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              //icon: '@android:drawable/btn_default_small'
            // other properties...
          ),
        )
    );
  }


}