import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sms_gateway/app_card.dart';
import 'package:sms_gateway/app_entity.dart';
import 'package:sms_gateway/app_repo.dart';
import 'package:sms_gateway/edit_app.dart';
import 'package:sms_gateway/sms_helper.dart';

class ManageAppsPage extends StatefulWidget {
  final FirebaseUser firebaseUser;

  ManageAppsPage(this.firebaseUser, {Key key}) : super(key: key);

  @override
  _ManageAppsPageState createState() => _ManageAppsPageState(firebaseUser);
}

class _ManageAppsPageState extends State<ManageAppsPage> with SmsHelper {
  final FirebaseUser firebaseUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppRepo _appRepo;
  Stream<List<AppEntity>> _appStream;

  _ManageAppsPageState(this.firebaseUser) : _appRepo = AppRepo(firebaseUser);

  @override
  void initState() {
    super.initState();
    _appStream = _appRepo.fetchApps();
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
        title: Text("Manage Apps"),
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

  void _newApp(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute<AppEntity>(
        builder: (context) => EditApp(firebaseUser),
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
