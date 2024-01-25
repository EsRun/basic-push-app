import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

// 백그라운드 푸시 핸들러
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage? message) async{
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  print('Handling a background message: ${message?.notification?.title}');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  showNotification(flutterLocalNotificationsPlugin, message!);
}

// 푸시 알림창 설정
Future<void> showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, RemoteMessage message) async {
  // foreground 알람을 위해 채널 생성
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'push main channel',
    //'high_importance_channel', // id
    'just channel', // title
    description: 'This channel is used for important notifications',
    importance: Importance.high,
  );

  const AndroidNotificationChannel channel2 = AndroidNotificationChannel(
    'push main channels',
    //'high_importance_channel', // id
    'second channel', // title
    description: 'This channel is used for important notifications',
    importance: Importance.high,
  );
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      channel);

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      channel2);

  if (message?.notification != null){
    flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message?.notification?.title,
        message?.notification?.body,
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

class Fcm{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 알림 설정 초기화
  Future<void> initNotification() async {
    messaging.subscribeToTopic('test');
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

    // 백그라운드 푸시 메소드(포그라운드와 별개로 선언 되어야 함)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await initPushNotification();
  }

  // 푸시 핸들러
  Future<void> initPushNotification() async{
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    //await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    //AndroidInitializationSettings initSettingAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    //InitializationSettings initSettings = InitializationSettings(android: initSettingAndroid);
    //flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(flutterLocalNotificationsPlugin, message);
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
}
