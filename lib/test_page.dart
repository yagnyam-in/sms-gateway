import 'package:flutter/material.dart';
import 'package:sms_gateway/model/app_state.dart';
import 'package:sms_gateway/sms_helper.dart';

class TestPage extends StatefulWidget {
  final AppState appState;

  TestPage({Key key, this.appState}) : super(key: key) {
    assert(appState != null);
  }

  @override
  _TestPageState createState() {
    return _TestPageState(appState);
  }
}

class _TestPageState extends State<TestPage> with SmsHelper {
  static const String TEST_PHONE_KEY = "testPhone";
  static const String TEST_MESSAGE_KEY = "testMessage";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AppState appState;

  final TextEditingController phoneController;
  final TextEditingController messageController;

  _TestPageState(this.appState)
      : phoneController = TextEditingController(
            text: appState.sharedPreferences.getString(TEST_PHONE_KEY)),
        messageController = TextEditingController(
            text: appState.sharedPreferences.getString(TEST_MESSAGE_KEY));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Test SMS"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 8.0),
              Text(
                "Test",
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                keyboardType: TextInputType.phone,
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                ),
                validator: (value) => _mandatoryFieldValidator(value),
              ),
              const SizedBox(height: 8.0),
              new TextFormField(
                keyboardType: TextInputType.text,
                controller: messageController,
                decoration: InputDecoration(
                  labelText: "Message",
                ),
                validator: (value) => _mandatoryFieldValidator(value),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: RaisedButton.icon(
                  onPressed: _submit,
                  icon: Icon(Icons.send),
                  label: Text("Send SMS"),
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

  @override
  void showToast(String toast) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(toast),
      duration: Duration(seconds: 3),
    ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    String phone = phoneController.text;
    String message = messageController.text;
    appState.sharedPreferences.setString(TEST_PHONE_KEY, phone);
    appState.sharedPreferences.setString(TEST_MESSAGE_KEY, message);
    sendSMS(phone: phone, message: message);
  }
}
