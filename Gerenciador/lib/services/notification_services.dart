
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/ui/theme.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
class NotifyHelper {
  FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin(); //
  String? selectedNotificationPayload;

  final BehaviorSubject<String?> selectNotificationSubject =
  BehaviorSubject<String?>();
  initializeNotification() async {
    _configureSelectNotificationSubject();
    await _configureLocalTimeZone();
    // await requestIOSPermissions(flutterLocalNotificationsPlugin);
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );
    final AndroidInitializationSettings androidInitializationSettings = new AndroidInitializationSettings("ic_launcher");
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (data) async {
          debugPrint('notification payload: ' + data.payload!);
                  selectNotificationSubject.add(data.payload);
        });
  }
  void requestIOSPermissions(
      ) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Exibe um diálogo com os detalhes da notificação e, ao tocar em "OK", redireciona para outra página.
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondScreen(payload),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  displayNotification({required String title, required String body}) async {
    print("fazendo teste");
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = new DarwinNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'você mudou o tema',
      'você mudou o tema de volta !',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }
  tz.TZDateTime _nextInstanceOfTenAM(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minutes);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
  scheduledNotification(int hour, int minutes,Task task) async {

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      task.note,
      _nextInstanceOfTenAM(hour, minutes),
  
      const NotificationDetails(
          android: AndroidNotificationDetails('seu id de canal',
              'nome do seu canal', )),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: "${task.title}|"+"${task.note}|"+"${task.startTime}|",
    );

  }
  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      debugPrint("Minha payload é "+payload!);
      await Get.to(()=>SecondScreen(payload));
    });
  }
  periodicalyNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('repetindo o id do canal',
        'repetindo o nome do canal', );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repetindo título',
        'repetindo corpo', RepeatInterval.everyMinute, platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }
}

class SecondScreen extends StatefulWidget {
  SecondScreen(this.payload);

  final String? payload;

  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String? _payload;

  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' ${_payload.toString().split("|")[0]}''}'),
      ),
      body: Container(

        child: Column(
            children:[
              SizedBox(height: 40,),
              Container(
                child: Column(
                    children:[
                      Text("olá, Giuliano", style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color:Color(0xFF162339)
                      ),),
                      SizedBox(
                        height: 10,
                      ),
                      Text("você tem um novo lembrete", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color:Colors.grey
                      ),),
                    ]

                ),
              ),
              SizedBox(height: 40,),
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  padding:const EdgeInsets.only(left: 30, right: 30, top:50),
                  margin: const EdgeInsets.only(left: 30, right: 30),
              
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          children: [
                            Icon(Icons.text_format,
                                size:35,
                                color:Colors.white
                            ),
                            SizedBox(width: 10,),
                            Text("Title",
                              style: TextStyle(
                                  color:Colors.white,
                                  fontSize: 30
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Text('${_payload.toString().split("|")[0]}''}',
                          style: TextStyle(
                              color:Colors.white,
                              fontSize: 20
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Icon(Icons.description,
                                size:35,
                                color:Colors.white
                            ),
                            SizedBox(width: 10,),
                            Text("Description",
                              style: TextStyle(
                                  color:Colors.white,
                                  fontSize: 30
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Text('${_payload.toString().split("|")[1]}''}',
                          style: TextStyle(
                              color:Colors.white,
                              fontSize: 20
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size:35,
                                color:Colors.white
                            ),
                            SizedBox(width: 10,),
                            Text("Data",
                              style: TextStyle(
                                  color:Colors.white,
                                  fontSize: 30
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Text('${_payload.toString().split("|")[2]}''}',
                          style: TextStyle(
                              color:Colors.white,
                              fontSize: 20
                          ),
                        )
                      ]
                  ),
                  decoration: BoxDecoration(
                      color:primaryClr,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50),
                          topLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                          bottomLeft: Radius.circular(50)
                      )
                  ),
                ),
              ),
              SizedBox(height: 140,)
            ]


        ),
      ),
    );
  }
}

