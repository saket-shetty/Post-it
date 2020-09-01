import 'package:flutter/material.dart';
import 'package:firebaseapp/homepage/category.dart';
import 'package:firebaseapp/user/message_page.dart';
import 'ShowDataPage.dart';

class allPostDataPage extends StatefulWidget {
  @override
  _allPostDataPageState createState() => _allPostDataPageState();
}

class _allPostDataPageState extends State<allPostDataPage> {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
                appBar: new AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Category()));
                },
                child: Icon(Icons.filter_list),
              ),
              Text(
                'Post it',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => message_page()));
                },
                child: Icon(
                  Icons.message,
                ),
              ),
            ],
          ),
        ),
        body: new ShowDataPage(),
      );
  }
}