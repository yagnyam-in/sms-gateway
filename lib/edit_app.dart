import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sms_gateway/db/app_repo.dart';
import 'package:sms_gateway/model/app_entity.dart';
import 'package:sms_gateway/sms_helper.dart';

import 'model/app_state.dart';

class EditApp extends StatefulWidget {
  final AppState appState;
  final AppEntity app;

  const EditApp(this.appState, {Key key, this.app}) : super(key: key);

  @override
  _EditAppState createState() {
    return _EditAppState(appState, app);
  }
}

class _EditAppState extends State<EditApp> with SmsHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AppState appState;
  final AppEntity app;

  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController accessTokenController;

  _EditAppState(this.appState, this.app)
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
                enabled: app == null,
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
    if (!AppEntity.idRegex.hasMatch(value)) {
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
      bool duplicateAppId =
          await AppRepo(appState).isAppIdTaken(idController.text);
      if (duplicateAppId) {
        showToast("App Id already taken");
        return null;
      }
      effectiveApp = AppEntity(
        userId: appState.userId,
        id: idController.text,
        name: nameController.text,
        description: descriptionController.text,
        accessToken: accessTokenController.text,
      );
    } else {
      effectiveApp = app.copy(
        name: nameController.text,
        description: descriptionController.text,
        accessToken: accessTokenController.text,
      );
    }
    try {
      effectiveApp = await AppRepo(appState).save(effectiveApp);
      Navigator.of(context).pop(effectiveApp);
    } catch (e) {
      print("Error Saving App: $e");
      showToast("$e");
    }
  }
}
