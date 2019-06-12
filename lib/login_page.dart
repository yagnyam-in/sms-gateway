import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sms_gateway/generic_helper.dart';
import 'package:sms_gateway/model/app_state.dart';

typedef AuthChangeCallback = void Function(FirebaseUser firebaseUser);

class LoginPage extends StatefulWidget {
  final AppState appState;
  final AuthChangeCallback authChangeCallback;

  const LoginPage(
    this.appState, {
    Key key,
    @required this.authChangeCallback,
  }) : super(key: key);

  @override
  _LoginPageState createState() {
    return _LoginPageState(
      appState,
      authChangeCallback,
    );
  }
}

class _LoginPageState extends State<LoginPage> with GenericHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AppState appState;
  final AuthChangeCallback authChangeCallback;

  final TextEditingController phoneController;
  final TextEditingController verificationCodeController =
      TextEditingController();
  final FocusNode verificationCodeControllerFocusNode = FocusNode();

  AuthCredential _authCredential;
  String _verificationId;
  bool _verificationCodeRequested = false;

  _LoginPageState(
    this.appState,
    this.authChangeCallback,
  ) : phoneController = TextEditingController(
          text: appState.sharedPreferences.getString("phone") ?? "",
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 8.0),
              Text(
                "Login with your phone number",
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                keyboardType: TextInputType.phone,
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                ),
                onEditingComplete: () => {},
                validator: (value) => _mandatoryFieldValidator(value),
              ),
              if (_verificationCodeRequested) const SizedBox(height: 8.0),
              if (_verificationCodeRequested)
                new TextFormField(
                  focusNode: verificationCodeControllerFocusNode,
                  keyboardType: TextInputType.text,
                  controller: verificationCodeController,
                  decoration: InputDecoration(
                    labelText: "Verification Code",
                  ),
                  validator: (value) => _mandatoryFieldValidator(value),
                ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: RaisedButton.icon(
                  onPressed: _submit,
                  icon: Icon(Icons.send),
                  label: Text(
                      _verificationCodeRequested ? "Login" : "Request Code"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mandatoryFieldValidator(String value) {
    if (value == null || value.isEmpty) {
      return "This field is mandatory";
    }
    return null;
  }

  void showToast(String toast) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(toast),
      duration: Duration(seconds: 3),
    ));
  }

  Future<void> _submit() async {
    if (_verificationCodeRequested) {
      _login();
    } else {
      _requestVerification();
    }
  }

  void _login() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    if (_authCredential == null) {
      showToast("Not yet ready");
    }
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: verificationCodeController.text,
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((user) {
      if (user != null) {
        authChangeCallback(user);
      }
    });
  }

  void _requestVerification() {
    String phone = phoneController.text;
    appState.sharedPreferences.setString("phone", phone);
    Future.delayed(const Duration(seconds: 30), () {
      setState(() {
        _verificationCodeRequested = false;
      });
    }).catchError((e) => null);
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 30),
      verificationCompleted: _verificationCompleted,
      verificationFailed: _verificationFailed,
      codeSent: _codeSent,
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
    );
  }

  void _verificationCompleted(AuthCredential credentials) {
    _authCredential = credentials;
    FirebaseAuth.instance.signInWithCredential(_authCredential).then((user) {
      if (user != null) {
        authChangeCallback(user);
      }
    });
  }

  void _verificationFailed(AuthException authException) {
    print("Failed to Verify Phone: ${authException.message}");
    showToast("Failed to Verify Phone: ${authException.message}");
  }

  void _codeSent(String verificationId, [int forceResendingToken]) {
    _verificationId = verificationId;
    setState(() {
      _verificationCodeRequested = true;
    });
    FocusScope.of(context).requestFocus(verificationCodeControllerFocusNode);
    showToast("Please check for the verification code");
  }

  void _codeAutoRetrievalTimeout(String verificationId) {
    print("_codeAutoRetrievalTimeout");
    _verificationId = verificationId;
  }
}
