import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseapp/data/userData.dart';
import 'package:firebaseapp/followers/follower.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebaseapp/user/userpost.dart';
import 'package:firebaseapp/main.dart';
import 'package:firebaseapp/followers/following.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/user/editProfile.dart';


class profile extends StatefulWidget {
  @override
  _profileState createState() => _profileState();
}


class _profileState extends State<profile> {
  String _newurl;
  int _newcount;
  String _userid;

  var _name;

  var status;
  var _about;

  final storage = new FlutterSecureStorage();

  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

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
    String userimage = await storage.read(key: 'user-image');

    if(userid != null){

      //............................FOLLOWING COUNT OF USER.............................

      ref.child('user').child('$userid').child('following').once().then((DataSnapshot snap) async{
        var key = await snap.value.keys;
        setState(() {
          this.followingcount = key.length;
        });

      });

      //............................POST COUNT OF USER.............................

      ref.child('user').child('$userid').child('post').once().then((DataSnapshot snap) async{
        var key = await snap.value.keys;

        setState(() {
          this.postcount = key.length;
        });
      });

      //............................FOLLOWERS COUNT OF USER.............................

      ref.child('user').child('$userid').child('follower').once().then((DataSnapshot snap) async{
        var key = await snap.value.keys;

        setState(() {
          this.followercount = key.length;
        });
      });

      //.........................USER STATUS..........................................

      ref.child('user').child('$userid').child('status').once().then((DataSnapshot snap) async{
        var statusvalue = await snap.value;

        setState(() {
          this.status = statusvalue;
        });
      });

      ref.child('user').child('$userid').child('about').once().then((DataSnapshot snap) async{
        var about = await snap.value;
        setState(() {
          this._about = about;
        });
      });
    }

    ref.child('user').child('$userid').child('name').once().then((DataSnapshot snap) async{
      var name = await snap.value;
      setState(() {
        this._name = name;
      });
    });

    setState(() {
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
    var device_width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent[200],
      appBar: new AppBar(
        actions: <Widget>[
          new IconButton(icon: Icon(Icons.edit), onPressed: (){
            final newdata = userData(_userid, _name, status, _about);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>editProfile(data: newdata,)));
          })
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: new Text("Profile",
        
          style: new TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),

      body:Column(
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
                          border: Border.all(
                            width: 1.0,
                            color: Colors.black38
                          ),
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(_newurl),
                                fit: BoxFit.cover,),
                            borderRadius: BorderRadius.all(Radius.circular(75.0)),
                          ),
                        ),
                      SizedBox(height: 10.0),
                      Text(
                        '$_name',
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                      ),
                      SizedBox(height: 10.0),
                      
                      Text(
                          '$status',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17.0,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              
                            ),
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

                              new Padding( padding:  new EdgeInsets.all(5)),
                              new Text('$_about',
                                  style: new TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                )
              ],
            ),
           ),
         ],
       ),
    );
  }
}
//end