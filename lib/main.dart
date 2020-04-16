import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:lets_live/pages/Home.dart';
import 'package:permission_handler/permission_handler.dart';
// Pages
import './pages/Login.dart';
import './pages/Register.dart';
import './pages/Channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tanyoe Live',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: App(),
      routes: {
        '/register': (context) => Register(),
        '/home': (context) => Home(),
        '/channel': (context) => Channel(),
      },
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool onLoading = true;

  @override
  void initState() {
    super.initState();
    currentSignIn();
    _handleCameraAndMic();
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [
        PermissionGroup.camera,
        PermissionGroup.microphone,
        PermissionGroup.storage,
      ],
    );
  }

  Future currentSignIn() async {
    try {
      FirebaseUser user = await auth.currentUser();
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          onLoading = false;
        });
      }
    } on PlatformException catch (e) {
      print("Error: $e");
      return Login();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (onLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Login();
    }
  }
}
