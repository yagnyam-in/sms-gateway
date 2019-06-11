import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_gateway/app_card.dart';
import 'package:sms_gateway/db/app_repo.dart';
import 'package:sms_gateway/db/request_repo.dart';
import 'package:sms_gateway/edit_app.dart';
import 'package:sms_gateway/model/app_entity.dart';
import 'package:sms_gateway/model/request_entity.dart';
import 'package:sms_gateway/service/notification_service.dart';
import 'package:sms_gateway/service/sms_service.dart';
import 'package:sms_gateway/sms_helper.dart';
import 'package:sms_gateway/test_page.dart';

class HomePage extends StatefulWidget {
  final FirebaseUser firebaseUser;

  HomePage(this.firebaseUser, {Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(firebaseUser);
}

class _HomePageState extends State<HomePage> with SmsHelper {
  final FirebaseUser firebaseUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<List<AppEntity>> _appStream;

  _HomePageState(this.firebaseUser);

  @override
  void initState() {
    super.initState();
    _appStream = AppRepo(firebaseUser).fetchApps();
    RequestRepo(firebaseUser)
        .subscribeForPendingRequests()
        .listen(_onPendingRequests);
    NotificationService.instance(firebaseUser).start();
  }

  void _onPendingRequests(List<RequestEntity> requests) {
    SmsService.processAllPendingRequests(firebaseUser, requests);
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
            icon: Icon(Icons.send),
            tooltip: "Apps",
            onPressed: () => _showTestPage(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        child: StreamBuilder<List<AppEntity>>(
          stream: _appStream,
          builder: _appsWidget,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _newApp(context),
        tooltip: 'New',
        child: Icon(Icons.add),
      ),
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

  void _newApp(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute<AppEntity>(
        builder: (context) => EditApp(firebaseUser),
      ),
    );
  }

  Widget _appsWidget(
      BuildContext context, AsyncSnapshot<List<AppEntity>> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text(snapshot.error.toString()),
      );
    } else if (!snapshot.hasData || snapshot.data.isEmpty) {
      return Center(
        child: Text("No Apps"),
      );
    } else {
      return ListView(
        children: snapshot.data.map((e) => appCard(context, e)).toList(),
      );
    }
  }

  Widget appCard(BuildContext context, AppEntity app) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: GestureDetector(
        child: AppCard(
          app: app,
        ),
        onTap: () => _editApp(context, app),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: "Delete",
          color: Colors.red,
          icon: Icons.archive,
          onTap: () => null,
        ),
      ],
    );
  }

  void _editApp(BuildContext context, AppEntity app) {
    Navigator.push(
      context,
      new MaterialPageRoute<AppEntity>(
        builder: (context) => EditApp(firebaseUser, app: app),
      ),
    );
  }
}
