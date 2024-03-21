import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_todo/auth/login.dart';
import 'package:firebase_todo/firebase_options.dart';
import 'package:firebase_todo/profile.dart';
import 'package:firebase_todo/provider/task_provider.dart';
import 'package:firebase_todo/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  bool isLogin = false;
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

  @override
  void initState() {
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
        home: !isLogin
            ? const LoginScreen()
            : Scaffold(
                body: TabBarView(
                  controller: tabController,
                  children: const [
                    TodoListScreen(),
                    ProfileScreen(),
                  ],
                ),
                bottomNavigationBar: SalomonBottomBar(
                  currentIndex: Provider.of<TaskProvider>(context, listen: true)
                      .currentTabIndex,
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
              ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/todolist': (context) => const TodoListScreen(),
          '/profile': (context) => const ProfileScreen(),
        });
  }
}
