import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_app/Notifications.dart';

class fcm2{

  //FlutterLocalNotificationsPlugin 패키지 초기화
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
    await Firebase.initializeApp();
  }

  // foreground 알람을 위해 채널 생성
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'notification_channel_id', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications',
    importance: Importance.max,
  );

  Future<void> messageNotification(RemoteMessage message)async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              //icon: '@mipmap/ic_launcher',
              icon: '@android:drawable/btn_default_small'
            // other properties...
          ),
        )
    );
  }

}