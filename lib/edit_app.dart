import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sms_gateway/app_entity.dart';
import 'package:sms_gateway/app_repo.dart';
import 'package:sms_gateway/sms_helper.dart';
import 'package:uuid/uuid.dart';

class EditApp extends StatefulWidget {
  final FirebaseUser firebaseUser;
  final AppEntity app;

  const EditApp(this.firebaseUser, {Key key, this.app}) : super(key: key);

  @override
  _EditAppState createState() {
    return _EditAppState(firebaseUser, app);
  }
}

class _EditAppState extends State<EditApp> with SmsHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseUser firebaseUser;
  final AppEntity app;

  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController accessTokenController;

  _EditAppState(this.firebaseUser, this.app)
      : idController = TextEditingController(text: app?.id),
        nameController = TextEditingController(text: app?.name),
        descriptionController = TextEditingController(text: app?.description),
        accessTokenController = TextEditingController(text: app?.accessToken);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(app == null ? "New App" : "Edit App"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 8.0),
              Text(
                "App details",
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: idController,
                decoration: InputDecoration(
                  labelText: "Id",
                ),
                validator: (value) => _appIdFieldValidator(value),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                ),
                validator: (value) => _mandatoryFieldValidator(value),
              ),
              const SizedBox(height: 8.0),
              new TextFormField(
                keyboardType: TextInputType.text,
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                ),
                validator: (value) => _mandatoryFieldValidator(value),
              ),
              const SizedBox(height: 8.0),
              new TextFormField(
                keyboardType: TextInputType.text,
                controller: accessTokenController,
                decoration: InputDecoration(
                  labelText: "Access Token",
                ),
                validator: (value) => _mandatoryFieldValidator(value),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: RaisedButton.icon(
                  onPressed: _save,
                  icon: Icon(Icons.save),
                  label: Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _appIdFieldValidator(String value) {
    String error = _mandatoryFieldValidator(value);
    if (error != null) {
      return error;
    }
    if (!AppEntity.ID_REGEX.hasMatch(value)) {
      return "Only alphabets and hyphens are allowed";
    }
    return null;
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

  Future<void> _save() async {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    AppEntity effectiveApp = app;
    if (effectiveApp == null) {
      effectiveApp = AppEntity(
        uid: Uuid().v4(),
        id: idController.text,
        name: nameController.text,
        description: descriptionController.text,
        accessToken: accessTokenController.text,
      );
    } else {
      effectiveApp = app.copy(
        id: idController.text,
        name: nameController.text,
        description: descriptionController.text,
        accessToken: accessTokenController.text,
      );
    }
    effectiveApp = await AppRepo(firebaseUser).save(effectiveApp);
    Navigator.of(context).pop(effectiveApp);
  }
}
