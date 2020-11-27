import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  final String fieldName;
  final String fieldData;

  InfoWidget({this.fieldData, this.fieldName});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(fieldName,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(fieldData,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              )),
          Divider(),
        ],
      ),
    );
  }
}