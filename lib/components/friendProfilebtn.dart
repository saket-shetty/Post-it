import 'package:flutter/material.dart';
import 'package:firebaseapp/components/profileButtonData.dart';
class profileButton extends StatelessWidget {

  final profileButtonData data;

  profileButton({this.data});

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: MediaQuery.of(context).size.width / 2 - 50,
      height: 40.0,
      child: new InkWell(
        onTap:this.data.onPress,
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.redAccent,
          shadowColor: Colors.redAccent.withOpacity(0.8),
          elevation: 7.0,
          child: Center(
            child: new Text(
              this.data.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
