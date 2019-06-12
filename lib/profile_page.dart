import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sms_gateway/db/app_repo.dart';
import 'package:sms_gateway/db/user_repo.dart';
import 'package:sms_gateway/generic_helper.dart';
import 'package:sms_gateway/model/app_state.dart';

typedef AuthChangeCallback = void Function(FirebaseUser firebaseUser);

class ProfilePage extends StatefulWidget {
  final AppState appState;
  final AuthChangeCallback authChangeCallback;

  ProfilePage({
    Key key,
    @required this.appState,
    @required this.authChangeCallback,
  }) : super(key: key) {
    assert(appState != null);
    assert(authChangeCallback != null);
  }

  @override
  _ProfilePageState createState() {
    return _ProfilePageState(
      appState: appState,
      authChangeCallback: authChangeCallback,
    );
  }
}

class _ProfilePageState extends State<ProfilePage> with GenericHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AppState appState;
  final AuthChangeCallback authChangeCallback;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController verificationCodeController =
      TextEditingController();
  final FocusNode verificationCodeControllerFocusNode = FocusNode();

  _ProfilePageState({
    @required this.appState,
    @required this.authChangeCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 8.0),
              Icon(Icons.account_circle, size: 64.0),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: RaisedButton.icon(
                  onPressed: _deleteAccount,
                  icon: Icon(Icons.delete),
                  label: Text("Delete Account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showToast(String toast) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(toast),
      duration: Duration(seconds: 3),
    ));
  }

  Future<void> _deleteAccount() async {
    await ignoreErrors(() => AppRepo(appState).deleteAllApps());
    await ignoreErrors(() => UserRepo(appState).delete());
    await FirebaseAuth.instance.signOut();
    authChangeCallback(null);
    Navigator.of(context).pop();
  }
}
