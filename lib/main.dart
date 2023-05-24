import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_project/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCqS2ohYfXrA6ksThBBXPl_ZAAwEBNGMZQ",
      appId: "1:158625938072:web:60a8807188aaabe63d2eed",
      messagingSenderId: "158625938072",
      projectId: "fir-auth-e9c5a",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.lightGreen,
      ),
      home: const WidgetTree(),
    );
  }
}
