import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:software_development/screens/home/start_page_UI.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
        title: 'Bracelyte',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xF0F6F9FF)
          //primarySwatch: Colors.blue,
        ),
        home: const StartPage(),
    );
  }
}

