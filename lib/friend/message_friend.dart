import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:time_machine/time_machine.dart';


class message_friend extends StatefulWidget {
  @override
  _message_friendState createState() => _message_friendState();
}

class _message_friendState extends State<message_friend> {
  final formKey = new GlobalKey<FormState>();

  TextEditingController _messagekey = new TextEditingController();
  ScrollController _controller = ScrollController();

  List<message_data> allData = [];

  List listofkeys = [];

  final storage = new FlutterSecureStorage();

  var friend_id, friend_profile, friend_name;

  var user_id, user_name, user_profile;

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  var _message;

  @override
  void initState() {
    // TODO: implement initState
    get_friend_detail();
    get_user_detail();
    get_message_detail();
    new_data_retrieve();

    super.initState();
  }

  Future get_friend_detail() async{
    friend_id = await storage.read(key: 'friend-id');
    friend_profile = await storage.read(key: 'friend-image');
    friend_name = await storage.read(key: 'friend-name');
    setState(() {
      
    });
  }

  Future get_user_detail() async{
    user_id = await storage.read(key: 'user-id');
    user_profile = await storage.read(key: 'user-image');
    user_name = await storage.read(key: 'user-name');
    setState(() {
      
    });
  }

  Future get_message_detail() async{
    user_id = await storage.read(key: 'user-id');
    friend_id = await storage.read(key: 'friend-id');
    ref.child('user').child('$user_id').child('message').child('$friend_id').once().then((DataSnapshot snap) async{
      var keys = await snap.value.keys;
      var newdata = await snap.value;

      for(var x in keys){
        listofkeys.add(x);
      }

      listofkeys.sort();
      listofkeys.reversed;

      for(var x in listofkeys){
        message_data msgdata = new message_data(newdata[x]['id'], newdata[x]['message'], newdata[x]['time']);
        allData.add(msgdata);
        setState(() {
          
        });
      }

    });

  }

  Future new_data_retrieve() async{
    user_id = await storage.read(key: 'user-id');
    friend_id = await storage.read(key: 'friend-id');
    ref.child('user').child('$user_id').child('message').child('$friend_id').onChildChanged.listen((snap){
      var key = snap.snapshot.key;
      var value = snap.snapshot.value;
      print('Child added : ${key}');
      print('Child added : ${value}');

      if(value['time'] != null){
        message_data data = new message_data(value['id'], value['message'], value['time']);
        allData.add(data);
      }

      setState(() {
        
      });
    });
    setState(() {
      
    });
  }

  void submit_message() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      submit_comment_database();
    }
  }

  void submit_comment_database() {
    var now = Instant.now();
    var timestamp = now.toString('yyyyMMddHHmmss');

    var time = DateTime.now();
    int hour;
    var state;

    if(time.hour > 12){
      hour = time.hour - 12;
      state = 'pm';
      setState(() {});
    }
    else{
      hour = time.hour;
      state = 'am';
      setState(() {});
    }

    var currentime = hour.toString()+":"+time.minute.toString()+' '+state;

    ref.child('user').child('$user_id').child('message').child('$friend_id').child('$timestamp').child('id').set('$user_id');
    ref.child('user').child('$user_id').child('message').child('$friend_id').child('$timestamp').child('message').set('$_message');
    ref.child('user').child('$user_id').child('message').child('$friend_id').child('$timestamp').child('time').set('$currentime');


    ref.child('user').child('$friend_id').child('message').child('$user_id').child('$timestamp').child('id').set('$user_id');
    ref.child('user').child('$friend_id').child('message').child('$user_id').child('$timestamp').child('message').set('$_message');
    ref.child('user').child('$friend_id').child('message').child('$user_id').child('$timestamp').child('time').set('$currentime');
  }


  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 10), () => _controller.jumpTo(_controller.position.maxScrollExtent));    
    return Scaffold(
      appBar: new AppBar(
        title: new Text('$friend_name',
          style: new TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: allData.length == 0 ? new Text('NO MESSAGE') :
             new ListView.builder(
              controller: _controller,
              itemCount: allData.length,
              itemBuilder: (_,index){
                return MessageUI(
                  allData[index].message_user_id,
                  allData[index].messagedata,
                  allData[index].time
                );
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.only(left: 5.0),
              ),
              new Padding(
                padding: new EdgeInsets.only(bottom: 3.0, top: 3.0),
                child: new Container(
                  width: (MediaQuery.of(context).size.width - 50),
                  height: 40.0,
                
                  child: new Form(
                    key: formKey,
                    child: Padding(
                      padding: new EdgeInsets.only(left: 0.0),
                      child: Center(
                        child: new TextFormField(
                          controller: _messagekey,
                          maxLines: 3,
                          cursorColor: Colors.deepPurpleAccent,
                          decoration: new InputDecoration(
                            hintText: 'Write a message',
                            
                            contentPadding: EdgeInsets.fromLTRB(20.0,5.0, 20.0, 13.0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
                          ),
                          
                          validator: (val) => val.length < 1
                              ? 'please enter message'
                              : null,
                          style: new TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                          onSaved: (val) => _message = val,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              new Padding(padding: new EdgeInsets.all(1.0)),
              new GestureDetector(
                onTap: () {
                  
                  //..................Send Message Function here....................
                  submit_message();
                  _messagekey.clear();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(50.0),
                    color: Colors.deepPurpleAccent,
                  ),
                  child: Center(
                    child: new Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ),
              ),
              new Padding(
                padding: new EdgeInsets.only(bottom: 05.0),
              )
            ],
          ),
        ],
      )
    );
  }

  Widget MessageUI(var id, var msg, var time){
    if(id == user_id){
      return new Align(
        alignment: Alignment.centerRight,
        child: Card(
          color: Color(0xFF4B8992),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text('$msg',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                    )
                  ),
                  new Padding(padding: new EdgeInsets.all(5),),
                  new Text('$time',
                    style: new TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    else{
      return new Align(
        alignment: Alignment.centerLeft,
        child: Card(
          color: Color(0xFFB9C2CA),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Row(
                mainAxisSize: MainAxisSize.min,

                children: <Widget>[
                  // new Text('$id'),
                  new Text('$time',
                    style: new TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  new Padding(padding: new EdgeInsets.all(5),),
                  new Text('$msg',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class message_data{
  var message_user_id;
  var messagedata;
  var time;

  message_data(this.message_user_id, this.messagedata, this.time);
}