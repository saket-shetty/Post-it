import 'package:firebaseapp/homepage/ShowDataPage.dart';
import 'package:firebaseapp/homepage/allPostDataPage.dart';
import 'package:flutter/material.dart';
import 'package:firebaseapp/data/friendProfile.dart';
import 'package:firebaseapp/data/sendMessageData.dart';
import 'package:firebaseapp/friend/message_friend.dart';
import 'package:firebaseapp/homepage/SearchPage.dart';
import 'package:firebaseapp/homepage/category.dart';
import 'package:firebaseapp/user/message_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/data/myData.dart';
import 'dart:async';
import 'package:firebaseapp/user/SubmitForm.dart';
import 'package:firebaseapp/user/profile.dart';
import 'dart:math' show Random;
import 'package:firebaseapp/homepage/display_message.dart';
import 'package:firebaseapp/friend/friendprofile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:line_icons/line_icons.dart';

class CategoryPost extends StatefulWidget {
  final String data;
  CategoryPost({this.data});
  @override
  _CategoryPostState createState() => _CategoryPostState();
}

class _CategoryPostState extends State<CategoryPost> {
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

  var _userid;

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  var _onTapIndex = 0;

  List<String> timestamplist = [];

  var _newname = '';
  var _userimage;
  List countofcomment = [];
  List countoflikes = [];
  int count = 0, likecount = 0;

  List likecolorlist = [];

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  int reportcount = 0;

  var report_status;

  Color _likecolor;

  int lastPostTime;

  Future get_user_detail() async {
    String userimage = await storage.read(key: 'user-image');
    String username = await storage.read(key: 'user-name');
    String userid = await storage.read(key: 'user-id');
    ref
        .child('user')
        .child('$userid')
        .child('lastPostTimestamp')
        .once()
        .then((DataSnapshot snap) {
      setState(() {
        if (snap.value == null) {
          lastPostTime = 0;
        } else {
          lastPostTime = int.parse(snap.value);
        }
      });
    });
    setState(() {
      _userimage = userimage;
      _newname = username;
      this._userid = userid;
    });
  }

  Future send_message_data(String message_name, msg_image, msg, timestamp,
      userid, likecount, cmntcount) async {
    sendMessageData sendData = new sendMessageData(
        message_name, msg_image, msg, timestamp, userid, likecount, cmntcount);

    setState(() {});
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => displaymessage(data: sendData)));
  }

  @override
  void initState() {
    get_user_detail();
    get_all_data();
    reportstatus();
    //retrieving data from firebase database
    //the data is stored using time so that we can sort the key and retrieve it in that format
    //snap.value will give the json format value and snap.value.key will give all the child/key the json contains.
  }

  Future get_all_data() async {
    await _userid;
    ref.child('category')
            .child('${this.widget.data}').limitToLast(20).once().then((DataSnapshot snap) {
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

        ref.child('category')
            .child('${this.widget.data}')
            .child('$newlist')
            .child('comments')
            .once()
            .then((DataSnapshot datasnap) {
          var key = datasnap.value.keys;
          count = key.length - 1;
          countofcomment.add(count);
          setState(() {});
        });

        //counting the number of likes the post got.
        //so that the user will get to know the amount of likes that his/her post got

        ref.child('category')
            .child('${this.widget.data}').child('$newlist').child('likes')
            .once()
            .then((DataSnapshot datasnap) {
            var key = datasnap.value.keys;
            likecount = key.length - 1;
            countoflikes.add(likecount);
            setState(() {});
        });

        timestamplist.add(newlist);

        ref.child('category')
            .child('${this.widget.data}')
            .child('$newlist')
            .child('likes')
            .child('$_userid')
            .once()
            .then((DataSnapshot snap) async {
          await _userid;
          var snapdata = snap.value;
          if (snapdata != null) {
            _likecolor = Colors.red;
            likecolorlist.add(0xFFFF0000);
          } else {
            _likecolor = Colors.white;
            likecolorlist.add(0xFFFFFFFF);
          }
          setState(() {});
        });

        myData d = new myData(
            data[newlist]['name'],
            data[newlist]['message'],
            data[newlist]['msgtime'],
            data[newlist]['image'],
            data[newlist]['userid'],
            data[newlist]['category']
            );
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

  _dislikesnackbar() {
    final snackbar = new SnackBar(
      content: new Text('Disliked'),
      duration: new Duration(milliseconds: 2000),
      backgroundColor: Colors.red,
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

  Future reportstatus() async {
    ref
        .child('user')
        .child(_userid)
        .child('Report')
        .once()
        .then((DataSnapshot snap) async {
      var data = await snap.value.keys;

      setState(() async {
        this.reportcount = data.length;
        if (reportcount >= 10) {
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
                '${this.widget.data}',
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _onTapIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              _onTapIndex = index;
              if(index==0){
                Navigator.push(context, new MaterialPageRoute(builder: (context)=> allPostDataPage()));
              }
              else if (index == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SubmitForm(data: lastPostTime)));

                setState(() {
                  _onTapIndex = 0;
                });
              } else if (index == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => searchPage()));
              } else if (index == 3) {
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
              icon: Icon(Icons.search),
              title: Text('SEARCH'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('PROFILE'),
            ),
          ],
        ),
        body: new Container(
          padding: EdgeInsets.only(top: 03.0),
//            margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: countofcomment.length == 0
              ? new Center(
                  child: new Text("No data in this category"),
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
                        likecolorlist[index],
                        allData[index].category
                        );
                  },
                ),
        ),
      ),
    );
  }

  Widget UI(
      String name,
      String message,
      String datetime,
      String image,
      String timestamp,
      int cmntcount,
      String userid,
      int likecount,
      int likecolor,
      List category
      ) {
    return new InkWell(
        onTap: () {
          sharemessage = message;
          send_message_data(
              name, image, message, timestamp, userid, likecount, cmntcount);
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: Column(
            children: <Widget>[
              Slidable(
                actionPane: new SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: new Card(
                  child: new Container(
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                      color: Color(color_value[Random().nextInt(5)]),
                    ),
                    padding: new EdgeInsets.only(top:10.0, bottom: 20.0, left: 10.0, right: 10.0),
                    child: new Column(
                      children: <Widget>[

                        new Row(
                          children: <Widget>[
                            new InkWell(
                              onTap: () {
                                // comparing the userid to check whether the userid is of the corrent user or the other user
                                // if the userid is of the current user show the user's profile
                                // if the userid is not of the current user show the profile of that user
                                if (_userid == userid) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => profile()));
                                } else {
                                  friendProfile fp =
                                      new friendProfile(userid, name, image);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              friendprofile(data: fp)));
                                }
                              },
                              child: new Container(
                                width: 40.0,
                                height: 40.0,
                                //margin: EdgeInsets.only(top: 30.0),
                                decoration: new BoxDecoration(
                                  border: Border.all(
                                    width: 1.5,
                                    color: Colors.white,
                                  ),
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new CachedNetworkImageProvider(
                                        '$image'),
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
                                  style: new TextStyle(color: Colors.white),
                                ),
                                new Text(
                                  '$datetime',
                                  style: new TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            new Expanded(child: new Container(),),
                            new Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.deepPurpleAccent,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left:8.0, right:8.0, top:2.0, bottom:2.0),
                                child: new Text('${this.widget.data}', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
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

                                    ref
                                        .child('node-name')
                                        .child('$timestamp')
                                        .child('likes')
                                        .once()
                                        .then((DataSnapshot snap) async {
                                      var data = snap.value.keys;

                                      var likefound = false;
                                      for (var x in data) {
                                        if (x == _userid) {
                                          likefound = true;
                                          _dislikesnackbar();
                                          ref
                                              .child('node-name')
                                              .child('$timestamp')
                                              .child('likes')
                                              .child('$_userid')
                                              .remove();
                                        }
                                      }
                                      if (likefound == false) {
                                        _likesnackbar();
                                        ref
                                            .child('node-name')
                                            .child('$timestamp')
                                            .child('likes')
                                            .child('$_userid')
                                            .child('name')
                                            .set('$_newname');
                                      }
                                    });
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
                                send_message_data(name, image, message,
                                    timestamp, userid, likecount, cmntcount);
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
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                    child: new IconSlideAction(
                      caption: 'Report',
                      color: Colors.redAccent,
                      icon: Icons.report,
                      onTap: () {
                        if (userid != _userid) {
                          ref
                              .child('user')
                              .child('$userid')
                              .child('Report')
                              .child('$_userid')
                              .set('1');
                          _report_user();
                        } else if (userid == _userid) {
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
                      onTap: () async {
                        if (userid != _userid) {
                          friendProfile fp =
                              new friendProfile(userid, name, image);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      message_friend(data: fp)));
                        } else if (userid == _userid) {
                          _same_user();
                        }
                      },
                    ),
                  )
                ],
              ),
              new Padding(
                padding: EdgeInsets.only(bottom: 10.0),
              ),
            ],
          ),
        ));
  }
}
//end
