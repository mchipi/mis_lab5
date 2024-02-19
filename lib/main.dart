
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mis_lab3/auth.dart';
import 'package:mis_lab3/calendar.dart';
import 'package:mis_lab3/create_exam.dart';
import 'package:mis_lab3/firebase_options.dart';
import 'package:mis_lab3/map.dart';
import 'package:mis_lab3/models/exam.dart';
import 'package:mis_lab3/controllers/notification_controller.dart';
import 'package:mis_lab3/models/location_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: "basic_channel_group",
      channelKey: "basic_channel",
      channelName: "basic_notif",
      channelDescription: "basic notification channel",
    )
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "basic_channel_group", channelGroupName: "basic_group")
  ]);


  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();

  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(const MyApp());
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ListScreen(),
        '/login': (context) => const AuthScreen(isLogin: true),
        '/register': (context) => const AuthScreen(isLogin: false),
      },
    );
  }
}



class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  _ListState createState() => _ListState();
}


class _ListState extends State<ListScreen> {
  final List<Exam> exams = [
    Exam(courseName: 'test', dateTime: DateTime.now()),
  ];
  final List<LocationModel> locations = [
    LocationModel(
      name: 'Skopje',
      latitude: 41.988466302674475,
      longitude: 21.46444417848708,
    ),
    LocationModel(
      name: 'Bitola',
      latitude: 41.025546,
      longitude: 21.340927,
    ),
    LocationModel(
      name: 'Ohrid',
      latitude: 41.1231,
      longitude: 20.8016,
    ),
    LocationModel(
      name: 'Struga',
      latitude: 41.1784,
      longitude: 20.6769,
    ),
    LocationModel(
      name: 'Kumanovo',
      latitude: 42.1323,
      longitude: 21.7141,
    ),
  ];

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceiveMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceiveMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreateMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayed);
    _scheduleNotificationsForExistingExams();
  }

  void _scheduleNotificationsForExistingExams() {
    for (int i = 0; i < exams.length; i++) {
      _scheduleNotification(exams[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: openMap,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: openCalendar,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => FirebaseAuth.instance.currentUser != null
                ? addNewExam(context)
                : _navigateToSignInPage(context),
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: logOut,
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final courseName = exams[index].courseName;
          final dateTime = exams[index].dateTime;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    dateTime.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Exams Scheduler App'),
      actions: [
        _buildAddExamButton(),
        _buildSignOutButton(),
      ],
    );
  }

  IconButton _buildAddExamButton() {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => FirebaseAuth.instance.currentUser != null
          ? addNewExam(context)
          : _navigateToSignInPage(context),
    );
  }

  IconButton _buildSignOutButton() {
    return IconButton(
      icon: const Icon(Icons.login),
      onPressed: () => logOut(),
    );
  }

  Widget _buildExamGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.courseName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  exam.dateTime.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 Future<void> addNewExam(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: CreateExamWidget(
              addExam: addExam,
            ),
          );
        });
  }

  void addExam(Exam exam) {
    setState(() {
      exams.add(exam);
      _scheduleNotification(exam);
    });
  }

  void _scheduleNotification(Exam exam) {
    final int notificationId = exams.indexOf(exam);

    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notificationId,
            channelKey: "basic_channel",
            title: exam.courseName,
            body: "You have an exam tomorrow!"),
        schedule: NotificationCalendar(
            day: exam.dateTime.subtract(const Duration(days: 1)).day,
            month: exam.dateTime.subtract(const Duration(days: 1)).month,
            year: exam.dateTime.subtract(const Duration(days: 1)).year,
            hour: exam.dateTime.subtract(const Duration(days: 1)).hour,
            minute: exam.dateTime.subtract(const Duration(days: 1)).minute));
  }


  void _navigateToSignInPage(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }


  void openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Calendar(exams: exams),
      ),
    );
  }

  void openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(locations: locations),
      ),
    );
  }


}







