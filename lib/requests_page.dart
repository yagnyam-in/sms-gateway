import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sms_gateway/db/request_repo.dart';
import 'package:sms_gateway/model/app_entity.dart';
import 'package:sms_gateway/model/app_state.dart';
import 'package:sms_gateway/model/request_entity.dart';
import 'package:sms_gateway/request_card.dart';
import 'package:sms_gateway/service/sms_service.dart';
import 'package:sms_gateway/sms_helper.dart';
import 'package:url_launcher/url_launcher.dart';

typedef AuthChangeCallback = void Function(FirebaseUser firebaseUser);

class RequestsPage extends StatefulWidget {
  final AppState appState;
  final AppEntity app;

  RequestsPage(this.appState, this.app, {Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(appState, app);
}

class _HomePageState extends State<RequestsPage> with SmsHelper {
  static const sendFromHomePage = false;
  final AppState appState;
  final AppEntity app;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<List<RequestEntity>> _requestsStream;

  _HomePageState(this.appState, this.app);

  @override
  void initState() {
    super.initState();
    _requestsStream = RequestRepo(appState).subscribeForApp(app.id);
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
        title: Text("${app.name} Requests"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            tooltip: "Help",
            onPressed: () => _showHelpPage(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        child: StreamBuilder<List<RequestEntity>>(
          stream: _requestsStream,
          builder: _requestsWidget,
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

  Widget _requestsWidget(BuildContext context, AsyncSnapshot<List<RequestEntity>> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text(snapshot.error.toString()),
      );
    } else if (!snapshot.hasData || snapshot.data.isEmpty) {
      return Center(
        child: Text("No Requests"),
      );
    } else {
      return ListView(
        children: snapshot.data.map((e) => requestCard(context, e)).toList(),
      );
    }
  }

  Widget requestCard(BuildContext context, RequestEntity request) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: RequestCard(
        request: request,
      ),
      actions: <Widget>[
        new IconSlideAction(
          caption: "Resend",
          color: Colors.orange,
          icon: Icons.refresh,
          onTap: () => _resend(context, request),
        ),
      ],
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: "Delete",
          color: Colors.red,
          icon: Icons.archive,
          onTap: () => _deleteRequest(context, request),
        ),
      ],
    );
  }

  Future<void> _resend(BuildContext context, RequestEntity request) {
    return SmsService.sendSMS(
      phone: request.phone,
      message: request.message,
    );
  }

  Future<void> _deleteRequest(BuildContext context, RequestEntity request) {
    return RequestRepo(appState).deleteRequest(request);
  }
}
