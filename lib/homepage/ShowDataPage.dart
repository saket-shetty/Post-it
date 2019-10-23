import 'package:firebaseapp/friend/message_friend.dart';
import 'package:firebaseapp/user/message_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/data/myData.dart';
import 'dart:async';
import 'package:firebaseapp/user/SubmitForm.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:firebaseapp/user/profile.dart';
import 'dart:math' show Random;
import 'package:firebaseapp/homepage/display_message.dart';
import 'package:firebaseapp/friend/friendprofile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flushbar/flushbar.dart';


class ShowDataPage extends StatefulWidget {
  @override
  _ShowDataPageState createState() => _ShowDataPageState();
}


class _ShowDataPageState extends State<ShowDataPage> {
  List<myData> allData = [];
  var sharemessage;

  final storage = new FlutterSecureStorage();

  // list of colors so that every post will have different color
  List<int> color_value = [
    0xFF4B0082,
    0xFFBA55D3,
    0xFFFF66FF,
    0xFFFF8C00,
    0xFFFF7F50
  ];

  var verify_email = '';
  var _userid;

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  static var time = new DateTime.now().millisecondsSinceEpoch;

  var _onTapIndex = 0;

  List<String> timestamplist = [];

  var _newname = '';
  var _userimage;
  List countofcomment = [];
  List countoflikes = [];
  int count = 0, likecount = 0;

  List likecolorlist = [];

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  int reportcount=0;

  var report_status;

  Color _likecolor;


  Future get_user_detail() async{
    String userimage = await storage.read(key: 'user-image');
    String username = await storage.read(key: 'user-name');
    String userid = await storage.read(key:'user-id');
    await storage.write(key: 'page-name', value:'init');
    setState(() {
     _userimage = userimage;
     _newname = username;
     _userid = userid;
    });
  }

  Future delete_data() async{
    await storage.delete(key: 'message-name');
    await storage.delete(key: 'message-image');
    await storage.delete(key: 'message');
    await storage.delete(key: 'timestamp');
    setState((){});
  }

  Future send_message_data(String message_name,msg_image,msg,timestamp) async{
    delete_data();
    await storage.write(key: 'message-name', value:'$message_name');
    await storage.write(key: 'message-image', value: '$msg_image');
    await storage.write(key: 'message', value: '$msg');
    await storage.write(key: 'timestamp', value: '$timestamp');
  
    setState(() {
      
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => displaymessage()));
  }

  Future welcome_snackbar() async{
    Flushbar(
      title: "Hello",
      message: "Welcome to Post it hope you like the app",
      duration: Duration(seconds: 2),
      isDismissible: true,
    )..show(context);
  }




  @override
  void initState() {

    get_user_detail();
    get_all_data();
    reportstatus();
    welcome_snackbar();

    //retrieving data from firebase database
    //the data is stored using time so that we can sort the key and retrieve it in that format
    //snap.value will give the json format value and snap.value.key will give all the child/key the json contains.

  }



  Future get_all_data() async{
    await _userid;
      ref.child('node-name').limitToLast(20).once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;

      List list = [];

      for (var key in keys) {
        list.add(key);
        list.sort();
      }

      var reversed = list.reversed;

      for (var newlist in reversed) {
        //counting the number of comment the post got.
        //so that the user will get to know the amount of comments that his/her post got

        ref.child('node-name').child('$newlist').child('comments').once().then((DataSnapshot datasnap) {
          var key = datasnap.value.keys;

          for (var x in key) {
            if (x != 'no-comments') {
              count = count + 1;
            } else if (x == 'no-comments') {
//              print('no comments hit :$x');
            }
          }
//          print('adding value count to list');
          countofcomment.add(count);
          count = 0;

          setState(() {});
        });

        //counting the number of likes the post got.
        //so that the user will get to know the amount of likes that his/her post got

        ref.child('node-name').child('$newlist').child('likes').once().then((DataSnapshot datasnap) {
          var key = datasnap.value.keys;
          for (var x in key) {
            if (x != 'no-likes') {
              likecount = likecount + 1;
            } else if (x == 'no-comments') {}
          }
          countoflikes.add(likecount);
          likecount = 0;

          setState(() {});
        });

        timestamplist.add(newlist);

        ref.child('node-name').child('$newlist').child('likes').child('$_userid').once().then((DataSnapshot snap) async{
          // print('this is user id $_userid');
          await _userid;
          var snapdata = snap.value;
          if(snapdata != null){
            _likecolor = Colors.red;
            likecolorlist.add(0xFFFF0000);
          }
          else{
            _likecolor = Colors.white;
            likecolorlist.add(0xFFFFFFFF);
          }
          setState(() {
            
          });
        });

        myData d = new myData(
            data[newlist]['name'],
            data[newlist]['message'],
            data[newlist]['msgtime'],
            data[newlist]['image'],
            data[newlist]['userid']);
        allData.add(d);
      }
      setState(() {});
    });
  }



  _likesnackbar() {
    final snackbar = new SnackBar(
      content: new Text('Liked'),
      duration: new Duration(milliseconds: 2000),
      backgroundColor: Colors.green,
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  _same_user() {
    final snackbar = new SnackBar(
      content: new Text('You cannot message yourself'),
      duration: new Duration(milliseconds: 2000),
      backgroundColor: Colors.green,
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  _report_yourself() {
    final snackbar = new SnackBar(
      content: new Text('You cannot report yourself'),
      duration: new Duration(milliseconds: 2000),
      backgroundColor: Colors.green,
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  _report_user() {
    final snackbar = new SnackBar(
      content: new Text('Reported'),
      duration: new Duration(milliseconds: 2000),
      backgroundColor: Colors.red,
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }



  Future store_friend_detail(String friendid, friendimage, friendname) async{
    await storage.write(key: 'friend-id', value: '$friendid');
    await storage.write(key: 'friend-image', value: '$friendimage');
    await storage.write(key: 'friend-name', value: '$friendname');
  }

  Future store_user_detail(String userid, userimage, username) async{
    await storage.write(key: 'user-id', value: '$userid');
    await storage.write(key: 'user-image', value: '$userimage');
    await storage.write(key: 'user-name', value: '$username');

    setState((){});
  }


  Future reportstatus() async {
      ref.child('user').child('550107170').child('Report').once().then((DataSnapshot snap) async {

        var data = await snap.value.keys;

        for(var key in data){
          reportcount++;
        }
        setState(() async {
          if(reportcount>=10){
            report_status = 'true';
            await storage.write(key: 'report-status', value: '$report_status');
          }
        });
      });
  }



  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,

        appBar: new AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Post it',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>message_page()));
              },
              child: Icon(
                Icons.message,

              ),
            ),
            new Padding(padding: new EdgeInsets.only(right: 10.0)),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _onTapIndex,
          onTap: (int index) {
            setState(() {
              _onTapIndex = index;
              if (index == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SubmitForm()));

                setState(() {
                  _onTapIndex = 0;
                });
              } else if (index == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => profile()));

                setState(() {
                  _onTapIndex = 0;
                });
              }
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: new Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.add),
              title: new Text('POST'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('PROFILE'),
            ),
          ],
        ),
        body: new RefreshIndicator(
          child: new Container(
            padding: EdgeInsets.only(top: 03.0),
//            margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: countofcomment.length == 0
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
                      return UI(
                        allData[index].name,
                        allData[index].message,
                        allData[index].msgtime,
                        allData[index].image,
                        timestamplist[index],
                        countofcomment[index],
                        allData[index].userid,
                        countoflikes[index],
                        likecolorlist[index]
                      );
                    },
                  ),
          ),
          onRefresh: _handleRefresh,
        ),
      ),
    );
  }

  Widget UI(String name, String message, String datetime, String image,
      String timestamp, int cmntcount, String userid, int likecount, int likecolor) {

    return new InkWell(
      onTap: () {
        sharemessage = message;
        delete_data();
        send_message_data(name,image,message,timestamp);

      },
      child: Container(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: Column(
          children: <Widget>[
            Slidable(
              delegate: new SlidableDrawerDelegate(),
              actionExtentRatio: 0.25,
              child: new Card(
                child: new Container(
                  color: Color(color_value[Random().nextInt(5)]),
                  padding: new EdgeInsets.all(20.0),
                  child: new Column(
                    children: <Widget>[
                      new Text(
                        '$message',
                        maxLines: 5,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.all(7.0),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              new GestureDetector(
                                onTap: () {
                                  // Update -> like message and display total count of like in profile
                                  ref.child('node-name').child('$timestamp').child('likes').child('$_userid').child('name').set('$_newname');
                                  _likesnackbar();
                                },
                                child: new Icon(
                                  LineIcons.heart,
                                  size: 20,
                                  color: Color(likecolor),
                                ),
                              ),
                              new Text(
                                '${likecount}',
                                style: new TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                          new GestureDetector(
                            onTap: () {
                              sharemessage = message;
                              delete_data();
                              send_message_data(name,image,message,timestamp);
                            },
                            child: Row(
                              children: <Widget>[
                                new Icon(
                                  Icons.chat_bubble_outline,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                countofcomment.length == 0
                                    ? new Text('0')
                                    : Text(
                                        '$cmntcount',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ],
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
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top:4.0, bottom:4.0),
                  child: new IconSlideAction(
                    caption: 'Report',
                    color: Colors.redAccent,
                    icon: Icons.report,
                    onTap: (){
                      if(userid != _userid){
                        ref.child('user').child('$userid').child('Report').child('$_userid').set('1');
                        _report_user();
                      }
                      else if(userid == _userid){
                        _report_yourself();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: new IconSlideAction(
                    icon: Icons.message,
                    caption: 'Message',
                    color: Colors.deepOrangeAccent,
                    onTap: () async{

                      if(userid != _userid){
                        await storage.write(key: 'friend-id', value: '$userid');
                        await storage.write(key: 'friend-name', value: '$name');
                        await storage.write(key: 'friend-image', value: '$image');

                        Navigator.push(context, MaterialPageRoute(builder: (context)=>message_friend()));
                      }
                      else if(userid == _userid){
                        _same_user();
                      }

                    },
                  ),
                )
              ],
            ),
            new Row(
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                new InkWell(
                  onTap: () {
                    // comparing the userid to check whether the userid is of the corrent user or the other user
                    // if the userid is of the current user show the user's profile
                    // if the userid is not of the current user show the profile of that user

                    if (_userid == userid) {

                      store_user_detail('$userid','$image','$name');
                      // have to reset the sharedpref so that the other users data should not get shown accidentally
                      Navigator.push(context, MaterialPageRoute(builder: (context) => profile()));
//                      print('user id :$userid');
                    } else {

                      store_friend_detail('$userid','$image','$name');
                      Navigator.push(context,MaterialPageRoute( builder: (context) => friendprofile()));
//                      print('friend id :$userid');
                    }
                  },
                  child: new Container(
                    width: 40.0,
                    height: 40.0,
                    //margin: EdgeInsets.only(top: 30.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new CachedNetworkImageProvider('$image'),
                      ),
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
                      '$name',
                    ),
                    new Text(
                      '$datetime',
                    ),
                  ],
                ),
              ],
            ),
            new Padding(
              padding: EdgeInsets.only(bottom: 10.0),
            ),
          ],
          ),
        )
      );
    }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 1));
    setState(() {
      Navigator.pop(context, MaterialPageRoute(builder: (context) => ShowDataPage()));
      Navigator.push(context, MaterialPageRoute(builder: (context) => ShowDataPage()));
    });
    return null;
  }
}

// building shredpref to store and share data with display_message.dart
//end
