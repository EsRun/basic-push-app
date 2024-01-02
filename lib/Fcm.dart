import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Fcm{

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initNoti() async {
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
    initPush();
  }
  
  Future<void> initPush() async{
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message title: ${message.notification?.title}');
      print('Message body: ${message.notification?.body}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }


}