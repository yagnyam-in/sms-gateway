import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sms_gateway/app_card.dart';
import 'package:sms_gateway/db/app_repo.dart';
import 'package:sms_gateway/edit_app.dart';
import 'package:sms_gateway/model/app_entity.dart';
import 'package:sms_gateway/model/app_state.dart';
import 'package:sms_gateway/profile_page.dart';
import 'package:sms_gateway/requests_page.dart';
import 'package:sms_gateway/service/notification_service.dart';
import 'package:sms_gateway/service/sms_service.dart';
import 'package:sms_gateway/sms_helper.dart';
import 'package:sms_gateway/test_page.dart';
import 'package:url_launcher/url_launcher.dart';

typedef AuthChangeCallback = void Function(FirebaseUser firebaseUser);

class HomePage extends StatefulWidget {
  final AppState appState;
  final AuthChangeCallback authChangeCallback;

  HomePage(this.appState, {Key key, @required this.authChangeCallback}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(appState, authChangeCallback);
}

class _HomePageState extends State<HomePage> with SmsHelper {
  final AppState appState;
  final AuthChangeCallback authChangeCallback;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<List<AppEntity>> _appStream;

  _HomePageState(this.appState, this.authChangeCallback);

  @override
  void initState() {
    super.initState();
    _appStream = AppRepo(appState).subscribeForApps();
    NotificationService.instance(appState).start();
    WidgetsBinding.instance.addPostFrameCallback(_acquireSmsPermissions);
    WidgetsBinding.instance.addPostFrameCallback(_processAllPendingRequests);
  }

  void _acquireSmsPermissions(Duration duration) {
    acquireSmsPermissions();
  }

  void _processAllPendingRequests(Duration duration) {
    SmsService.processAllPendingRequests(appState);
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
            icon: Icon(Icons.info),
            tooltip: "Help",
            onPressed: () => _showHelpPage(context),
          ),
          IconButton(
            icon: Icon(Icons.build),
            tooltip: "Test",
            onPressed: () => _showTestPage(context),
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            tooltip: "Profile",
            onPressed: () => _showProfilePage(context),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestPage(
          appState: appState,
        ),
      ),
    );
  }

  void _showProfilePage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          appState: appState,
          authChangeCallback: authChangeCallback,
        ),
      ),
    );
  }

  void _showHelpPage(BuildContext context) async {
    launch(
      "https://www.sg.yagnyam.in/faq",
      forceSafariVC: false,
      forceWebView: false,
    );
  }

  void _newApp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<AppEntity>(
        builder: (context) => EditApp(appState),
      ),
    );
  }

  Widget _appsWidget(BuildContext context, AsyncSnapshot<List<AppEntity>> snapshot) {
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
        onTap: () => _launchRequests(context, app),
      ),
      actions: <Widget>[
        new IconSlideAction(
          caption: "Edit",
          color: Colors.orange,
          icon: Icons.edit,
          onTap: () => _editApp(context, app),
        ),
      ],
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: "Delete",
          color: Colors.red,
          icon: Icons.archive,
          onTap: () => _deleteApp(context, app),
        ),
      ],
    );
  }

  void _editApp(BuildContext context, AppEntity app) {
    Navigator.push(
      context,
      new MaterialPageRoute<AppEntity>(
        builder: (context) => EditApp(appState, app: app),
      ),
    );
  }

  void _deleteApp(BuildContext context, AppEntity app) {
    AppRepo(appState).delete(app.id);
  }

  void _launchRequests(BuildContext context, AppEntity app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestsPage(appState, app),
      ),
    );
  }
}
