import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:task_app/firebase_options.dart';
import 'package:task_app/home_page.dart';
import 'package:task_app/login_screen.dart';
import 'package:task_app/notes_page.dart';
import 'package:task_app/pages_nav.dart';
import 'package:task_app/screen/add_transaction.dart';
import 'package:task_app/screen/borrow_and_lend_page.dart';
import 'package:task_app/screen/expense_chart.dart';
import 'package:task_app/screen/expense_track_page.dart';
import 'package:task_app/screen/splash_screen.dart';
import 'package:task_app/sign_up.dart';
import 'package:task_app/todo_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
//FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const HomePage(),
      //home: (FirebaseAuth.instance.currentUser != null)? HomePage():SignUp(),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (context,snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(),);

        }

        if(snapshot.data != null){
           return HomePage();
        }
             return SignUp();
      }),
    );
  }
}
