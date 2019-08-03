import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseapp/followers/follower.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebaseapp/user/userpost.dart';
import 'package:firebaseapp/main.dart';
import 'package:firebaseapp/followers/following.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';


class profile extends StatefulWidget {
  @override
  _profileState createState() => _profileState();
}


class _profileState extends State<profile> {
  String _newurl;
  String _newname;
  int _newcount;
  String _userid;

  var status;
  var _about;

  final storage = new FlutterSecureStorage();

  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  bool displaystatus = true;
  bool _displayabout = true;

  TextEditingController _status = new TextEditingController();
  TextEditingController _aboutcontroller = new TextEditingController();

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  //..............PROFILE VARIABLE..................

  int postcount = 0;
  int followercount = 0;
  int followingcount = 0;

  @override
  void initState() {
    // TODO: implement initState
    get_user_detail();
  }

  Future get_user_detail() async{
    String userid = await storage.read(key: 'user-id');
    String username = await storage.read(key: 'user-name');
    String userimage = await storage.read(key: 'user-image');

    if(userid != null){

      //............................FOLLOWING COUNT OF USER.............................

      ref.child('user').child('$userid').child('following').once().then((DataSnapshot snap) async{
        var key = await snap.value.keys;

        for(var following in key){
          followingcount++;
        }
        print('this is keys ${key}');
        setState(() {
          
        });
      });

      //............................POST COUNT OF USER.............................

      ref.child('user').child('$userid').child('post').once().then((DataSnapshot snap) async{
        var key = await snap.value.keys;
        for(var post in key){
          postcount ++;
        }
        print('post count :$postcount');
        print('Post key :$key');

        setState(() {
          
        });
      });

      //............................FOLLOWERS COUNT OF USER.............................

      ref.child('user').child('$userid').child('follower').once().then((DataSnapshot snap) async{
        var key = await snap.value.keys;
        for(var post in key){
          followercount++;
        }
        print('follower count :$followercount');
        print('Post key :$key');

        setState(() {
          
        });
      });

      //.........................USER STATUS..........................................

      ref.child('user').child('$userid').child('status').once().then((DataSnapshot snap) async{
        var statusvalue = await snap.value;
        print('status :$statusvalue');

        setState(() {
          status = statusvalue;
          _status.text = status;
        });
      });

      ref.child('user').child('$userid').child('about').once().then((DataSnapshot snap) async{
        var about = await snap.value;
        print('about :$about');

        setState(() {
          _about = about;
          _aboutcontroller.text = _about;
        });
      });

    }

    setState(() {
     _newname = username;
     _newurl = userimage;
     _userid = userid;
    });
  }

  TextStyle textstyle = new TextStyle(
    color: Colors.white,
  );

  Future signout() async {
    googleSignIn.signOut();
    await storage.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    var topheight = MediaQuery.of(context).padding.top;
    var device_width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF44473E),

      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: new Text("PROFILE",
        
          style: new TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300,

          ),
        ),
      ),

      body:
      
       Column(
         children: <Widget>[
          // new Padding(padding: new EdgeInsets.all(5),),
          Align(
            alignment: Alignment.centerRight,
            child: FlatButton(
              child: new Text('Log Out',
                style: new TextStyle(
                  color: Colors.white
                ),
              ),
              onPressed: (){
                signout();
                Navigator.push(context, MaterialPageRoute(builder: (context)=>homepage()));
              },
            ),
          ),
          // new Padding(padding: new EdgeInsets.all(5),),
           Expanded(
            child: new Stack(
              children: <Widget>[
                Positioned(
                  width: device_width,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 150.0,
                        height: 150.0,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(_newurl),
                                fit: BoxFit.cover,),
                            borderRadius: BorderRadius.all(Radius.circular(75.0)),
                            boxShadow: [
                              BoxShadow(blurRadius: 7.0, color: Colors.black)
                            ])),
                      SizedBox(height: 10.0),
                      Text(
                        '$_newname',
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Montserrat',
                            color: Color(0xFFFD9D5C)  
                          ),
                      ),
                      SizedBox(height: 10.0),

                      displaystatus == true ?

                      GestureDetector(
                        onTap: (){
                          displaystatus = false;
                          _displayabout = true;
                          print('status click');
                          setState(() {
                            
                          });
                        },
                        child: Text(
                          '$status',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17.0,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              
                            ),
                        ),
                      )

                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(left:8.0, right: 8.0),
                            width: MediaQuery.of(context).size.width-50,
                            child: new TextFormField(
                              autofocus: true,
                              style: new TextStyle(
                                color: Colors.white
                              ),
                              cursorColor: Colors.deepPurpleAccent,
                              controller: _status,
                              decoration: new InputDecoration(
                                hintText: 'Status',
                                contentPadding: EdgeInsets.fromLTRB(20.0,5.0, 20.0, 13.0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),),
                              )
                            ),
                          ),
                          new IconButton(
                            icon:Icon(
                              Icons.send,
                              color: Colors.deepPurpleAccent,
                            ),
                            onPressed: (){
                              displaystatus = true;
                              print('${_status.text}');
                              setState(() {
                                ref.child('user').child('$_userid').child('status').set(_status.text);
                                setState(() {
                                  
                                });
                              });
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 15.0),

                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>follower()));
                            },
                            child: new Column(
                              children: <Widget>[
                                new Text('$followercount',
                                  style: textstyle,
                                ),
                                new Text('Followers',
                                  style: textstyle,
                                ),
                              ],
                            ),
                          ),

                          Container(color: Colors.black45, height: 30.0, width: 2,),

                          new GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>following()));
                            },
                            child: new Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Text('$followingcount',
                                  style: textstyle,
                                ),
                                new Text('Following',
                                  style: textstyle,
                                ),
                              ],
                            ),
                          ),

                          Container(color: Colors.black45, height: 30.0, width: 2,),

                          new GestureDetector(
                            onTap: (){
                              Navigator.push(context,MaterialPageRoute(builder: (context) => userpost()));
                            },
                            child: new Column(
                              children: <Widget>[
                                new Text('$postcount',
                                  style: textstyle,
                                ),
                                new Text('Post',
                                  style: textstyle,
                                )
                              ],
                            ),
                          ),

                        ],
                      ),

                      SizedBox(height: 15.0),

                      new Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text('About',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0
                                ),
                              ),

                              new GestureDetector(
                                onTap: (){
                                  _displayabout = false;
                                  displaystatus = true;
                                  
                                  setState((){});
                                },
                                child: new Text('$_about',
                                  style: new TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),

                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.push(context,
                      //         MaterialPageRoute(builder: (context) => userpost()));
                      //   },
                      //   child: Container(
                      //     height: 50.0,
                      //     width: 150.0,
                      //     child: Material(
                      //       borderRadius: BorderRadius.circular(25.0),
                      //       shadowColor: Colors.greenAccent,
                      //       color: Colors.green,
                      //       elevation: 7.0,
                      //       child: Center(
                      //         child: Text(
                      //           'POSTS',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontFamily: 'Montserrat',
                      //             fontWeight: FontWeight.w300,
                      //             fontSize: 15.0
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 25.0),
                      // GestureDetector(
                      //   onTap: (){
                      //     Navigator.push(context, MaterialPageRoute(builder: (context)=>following()));
                      //   },
                      //   child: Container(
                      //       height: 50.0,
                      //       width: 150.0,
                      //       child: Material(
                      //         borderRadius: BorderRadius.circular(25.0),
                      //         shadowColor: Colors.cyanAccent,
                      //         color: Colors.cyan,
                      //         elevation: 7.0,
                      //         child: Center(
                      //           child: Text(
                      //             'Following',
                      //             style: TextStyle(
                      //               color: Colors.white,
                      //               fontFamily: 'Montserrat',
                      //               fontWeight: FontWeight.w300,
                      //               fontSize: 15.0
                      //             ),
                      //           ),
                      //         ),
                      //       )),
                      // ),
                      // SizedBox(height: 25.0),
                      // GestureDetector(
                      //   onTap: (){
                      //     signout();
                      //     Navigator.push(context, MaterialPageRoute(builder: (context)=>homepage()));
                      //   },
                      //   child: Container(
                      //       height: 50.0,
                      //       width: 150.0,
                      //       child: Material(
                      //         borderRadius: BorderRadius.circular(25.0),
                      //         shadowColor: Colors.redAccent,
                      //         color: Colors.red,
                      //         elevation: 7.0,
                      //         child: Center(
                      //           child: Text(
                      //             'Log out',
                      //             style: TextStyle(
                      //               color: Colors.white,
                      //               fontFamily: 'Montserrat',
                      //               fontWeight: FontWeight.w300,
                      //               fontSize: 15.0
                      //             ),
                      //           ),
                      //         ),
                      //       )),
                      // ),



                    ],
                  ),
                )
              ],
            ),
           ),


            _displayabout == false ? new Row(
              children: <Widget>[

                Container(
                  // padding: const EdgeInsets.only(left:8.0, right: 8.0),
                  width: MediaQuery.of(context).size.width-50,
                  child: new TextFormField(
                    validator: (val) => val.length < 1 ? 'Please enter some content' : null,
                    maxLines: 3,
                    maxLength: 80,
                    autofocus: true,
                    style: new TextStyle(
                      color: Colors.white
                    ),
                    cursorColor: Colors.deepPurpleAccent,
                    controller: _aboutcontroller,
                    decoration: new InputDecoration(
                      hintText: 'About',
                      hintStyle: new TextStyle(
                        color: Colors.white,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(20.0,5.0, 20.0, 13.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),),
                    )
                  ),
                ),

                new IconButton(
                  icon:Icon(
                    Icons.send,
                    color: Colors.deepPurpleAccent,
                    size: 25.0,
                  ),
                  
                  onPressed: (){
                    _displayabout = true;
                    print('${_aboutcontroller.text}');
                    setState(() {
                      ref.child('user').child('$_userid').child('about').set(_aboutcontroller.text);
                      setState(() {
                        
                      });
                    });
                  },
                ),
              ],
              
            ) : new Container(),
         ],
       ),
    );
  }
}
//end