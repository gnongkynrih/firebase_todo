import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_todo/auth/login.dart';
import 'package:firebase_todo/firebase_options.dart';
import 'package:firebase_todo/widget/no_internet_screen.dart';
import 'package:firebase_todo/screen/profile.dart';
import 'package:firebase_todo/provider/task_provider.dart';
import 'package:firebase_todo/screen/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

Future<bool> checkConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  } else {
    return true;
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  bool hasInternetConnection = await checkConnectivity();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
      // webRecaptchaSiteKey: 'recaptcha-v3-site-key',
      // Set androidProvider to `AndroidProvider.debug`
      androidProvider: AndroidProvider.debug,
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: TodoApp(
        hasInternetConnection: hasInternetConnection,
      ),
    ),
  );
}

class TodoApp extends StatefulWidget {
  TodoApp({super.key, required this.hasInternetConnection});
  bool hasInternetConnection;
  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> with SingleTickerProviderStateMixin {
  bool isLogin = false;
  late StreamSubscription<ConnectivityResult> subscription;

  late TabController tabController;
  initialize() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      setState(() {
        isLogin = true;
      });
    }
    FlutterNativeSplash.remove();
  }

  monitorInternetConnection() {
    //monitor internet connectivity
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          widget.hasInternetConnection = false;
        });
      } else {
        setState(() {
          widget.hasInternetConnection = true;
        });
      }
    });
  }

  @override
  void initState() {
    monitorInternetConnection();
    initialize();
    tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex:
            Provider.of<TaskProvider>(context, listen: false).currentTabIndex);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: showScreen(widget.hasInternetConnection),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/todolist': (context) => const TodoListScreen(),
          '/profile': (context) => const ProfileScreen(),
        });
  }

  showScreen(bool internetConnection) {
    if (internetConnection) {
      if (!isLogin) {
        return const LoginScreen();
      } else {
        return TabBarWidget(tabController: tabController, context: context);
      }
    } else {
      return const NoInternetScreen();
    }
  }
}

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({
    super.key,
    required this.tabController,
    required this.context,
  });

  final TabController tabController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        children: const [
          TodoListScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex:
            Provider.of<TaskProvider>(context, listen: true).currentTabIndex,
        onTap: (index) {
          tabController.animateTo(index);
          Provider.of<TaskProvider>(context, listen: false)
              .updateCurrentTabIndex(index);
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.list),
            title: const Text('Todo List'),
            selectedColor: Colors.deepPurple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text('Profile'),
            selectedColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}
