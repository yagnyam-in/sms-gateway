import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_gateway/generic_helper.dart';
import 'package:sms_gateway/home_page.dart';
import 'package:sms_gateway/login_page.dart';
import 'package:sms_gateway/model/app_state.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> with GenericHelper {
  Future<AppState> _appStateFuture;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _appStateFuture = _fetchAppState();
  }

  @override
  Widget build(BuildContext context) {
    print("creating app, _loggedIn: $_loggedIn");
    return MaterialApp(
      title: 'SMS Gateway',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _appStateFuture,
        builder: _buildHome,
      ),
    );
  }

  Widget _buildHome(BuildContext context, AsyncSnapshot<AppState> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text("${snapshot.error}"),
      );
    } else if (!snapshot.hasData) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (snapshot.data.firebaseUser == null) {
      return LoginPage(
        snapshot.data,
        authChangeCallback: _onAuthChange,
      );
    } else {
      _loggedIn = true;
      return HomePage(
        snapshot.data,
        authChangeCallback: _onAuthChange,
      );
    }
  }

  void _onAuthChange(FirebaseUser firebaseUser) {
    print("_onAuthChange($firebaseUser}");
    setState(() {
      _loggedIn = firebaseUser != null;
      try {
        _appStateFuture = _fetchAppState();
      } catch (e) {
        print("Error changing user $e");
      }
    });
  }

  Future<AppState> _fetchAppState() async {
    return AppState(
      firebaseUser: await FirebaseAuth.instance.currentUser(),
      sharedPreferences: await SharedPreferences.getInstance(),
    );
  }
}
