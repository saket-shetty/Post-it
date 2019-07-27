import 'package:flutter/material.dart';

class setting extends StatefulWidget {
  @override
  _settingState createState() => _settingState();
}

class _settingState extends State<setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        title: new Text(
          'Setting',
          style: new TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
//end