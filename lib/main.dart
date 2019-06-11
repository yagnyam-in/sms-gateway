import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sms_gateway/home_page.dart';
import 'package:sms_gateway/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  Future<FirebaseUser> _firebaseUserFuture;

  @override
  void initState() {
    super.initState();
    _firebaseUserFuture = FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Gateway',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _firebaseUserFuture,
        builder: _buildHome,
      ),
    );
  }

  Widget _buildHome(BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text("${snapshot.error}"),
      );
    } else if (!snapshot.hasData) {
      return LoginPage(callback: _onLogin,);
    } else {
      return HomePage(snapshot.data);
    }
  }

  void _onLogin(FirebaseUser firebaseUser) {
    setState(() {
      _firebaseUserFuture = Future.value(firebaseUser);
    });
  }


}
