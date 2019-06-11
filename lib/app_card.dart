import 'package:flutter/material.dart';
import 'package:sms_gateway/model/app_entity.dart';

class AppCard extends StatelessWidget {
  final AppEntity app;

  AppCard({Key key, this.app}) : super(key: key) {
    assert(app != null);
  }

  @override
  Widget build(BuildContext context) {
    print(app);
    return makeCard(context);
  }

  Widget makeCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: new EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Container(
        decoration: BoxDecoration(),
        child: makeListTile(context),
      ),
    );
  }

  Widget makeListTile(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text(
        app.name ?? app.id,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          app.description ?? app.id ?? "",
        ),
      ),
      trailing: Text(
        "${app.smsCount ?? 0}",
        style: themeData.textTheme.title,
      ),
    );
  }
}
