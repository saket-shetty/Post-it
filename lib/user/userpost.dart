import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:firebaseapp/user/userpostdata.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class userpost extends StatefulWidget {
  @override
  _userpostState createState() => _userpostState();
}


class _userpostState extends State<userpost> {
  List<userpostdata> allData = [];
  var verify_email = '';
  var _userid = '';
  String _newname;
  String _newimgurl;

  var name='';
  var imageurl='';

  List normalkey = [];

  final storage = new FlutterSecureStorage();

  List new_normalkey = [];

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  void initState() {

    get_user_detail();

    setState(() {});
    _comments();
    // get email of the user
  }

  Future get_user_detail() async{
    String userid = await storage.read(key: 'user-id');
    String username = await storage.read(key: 'user-name');
    String userimage = await storage.read(key: 'user-image');

    setState(() {
     _newname = username;
     _newimgurl = userimage;
     _userid = userid;
    });
  }

  Future<String> _comments() async {
    await new Future.delayed(
      new Duration(milliseconds: 200),
      () {
        ref.child('user').child('$_userid').child('post').once().then((DataSnapshot snap) {
          var data = snap.value;
          var key = snap.value.keys;

          for(var y in key){
            normalkey.add(y);
          }

          for(var x in normalkey){
            new_normalkey.add(x);
            new_normalkey.sort();
          }
          var reversed = new_normalkey.reversed;

          for (var x in reversed) {
              userpostdata userdata = new userpostdata(data[x]['message'], data[x]['msgtime']);
              allData.add(userdata);
          }
          setState(() {});
        });
      },
    );

    if(_userid == null){
      _comments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        title: new Text(
          'YOU POSTED',
          style: new TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      body: new Container(
        padding: EdgeInsets.only(top: 03.0),
        child: allData.length == 0
            ? new Center(
                child: FlareActor(
                  'asset/linear.flr',
                  animation: 'linear',
                  fit: BoxFit.contain,
                ),
              )
            : new ListView.builder(
                itemCount: allData.length,
                itemBuilder: (_, index) {
                  return UI(allData[index].message, allData[index].msgtime);
                },
              ),
      ),
    );
  }

  Widget UI(String message, String time) {
    return Container(
      width: 300,
      margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Column(
        children: <Widget>[
          new Card(
            child: new Container(
              color: Colors.deepOrangeAccent,
              padding: new EdgeInsets.all(20.0),
              child: new Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.all(2.0),
                  ),
                  new Text(
                    '$message',
                    maxLines: 5,
//                    style: Theme.of(context).textTheme.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  new Padding(
                    padding: EdgeInsets.all(2.0),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new GestureDetector(
                        onTap: () {
                          // Update -> like message and display total count of like in profile
                        },
                        child: new Icon(
                          Icons.thumb_up,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      new GestureDetector(
                        onTap: () {
                          // Update -> comment on message
                        },
                        child: new Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      new GestureDetector(
                        onTap: () {
                          // Update -> Add new functionality
                        },
                        child: new Icon(
                          Icons.star_border,
                          size: 20,
                          color: Colors.white,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          new Row(
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.all(10.0),
              ),
              new Container(
                width: 40.0,
                height: 40.0,
                //margin: EdgeInsets.only(top: 30.0),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage('$_newimgurl'),
                  ),
                ),
              ),
              new Padding(
                padding: EdgeInsets.only(right: 10.0),
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    '$_newname',
//                    style: TextStyle(color: Colors.white),
                  ),
                  new Text(
                    '$time',
                  ),
                ],
              ),
            ],
          ),
          new Padding(
            padding: EdgeInsets.only(bottom: 5.0),
          ),
        ],
      ),
    );
  }
}
//end