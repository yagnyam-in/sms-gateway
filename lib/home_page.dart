import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_gateway/notification_service.dart';
import 'package:sms_gateway/sms_helper.dart';
import 'package:sms_gateway/test_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SmsHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.instance().start();
  }

  void showToast(String toast) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(toast),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("SMS Gateway"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_balance),
            tooltip: "Apps",
            onPressed: () => _manageApps(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'SMS Sent',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTestPage(context),
        tooltip: 'Send',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showTestPage(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => TestPage(sharedPreferences: sharedPreferences),
      ),
    );
  }

  void _manageApps(BuildContext context) {

  }
}
