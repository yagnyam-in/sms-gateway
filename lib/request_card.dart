import 'package:flutter/material.dart';
import 'package:sms_gateway/model/request_entity.dart';

class RequestCard extends StatelessWidget {
  final RequestEntity request;

  RequestCard({Key key, this.request}) : super(key: key) {
    assert(request != null);
  }

  @override
  Widget build(BuildContext context) {
    print(request);
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
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text(
        request.phone,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          request.message,
        ),
      ),
    );
  }
}
