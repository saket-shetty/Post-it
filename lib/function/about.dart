import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class about extends StatefulWidget {
  @override
  _aboutState createState() => _aboutState();
}

class _aboutState extends State<about> {

  var _userid;
  var _about;
  DatabaseReference ref = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    // TODO: implement initState
    getaboutdata();
    super.initState();
  }

  Future getaboutdata() async{
    await Future.delayed(Duration(milliseconds: 100),(){
      ref.child('user').child('$_userid').child('about').once().then((DataSnapshot snap){
        var data = snap.value;
        print('about data :$data');
        setState(() {
          _about = data;
        });
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        title: new Text(
          'ABOUT',
          style: new TextStyle(fontWeight: FontWeight.w300, fontSize: 18.0),
        ),
      ),
      body: new Container(
        child: new Center(
          child: new Text('$_about'),
        ),
      ),
    );
  }
}
//end