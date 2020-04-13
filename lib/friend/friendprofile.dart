import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebaseapp/data/friendProfile.dart';
import 'package:firebaseapp/friend/friend_follower.dart';
import 'package:firebaseapp/friend/friend_following.dart';
import 'package:firebaseapp/friend/message_friend.dart';
import 'package:flutter/material.dart';
import 'package:firebaseapp/user/profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/friend/friendpost.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class friendprofile extends StatefulWidget {
  @override
  final friendProfile data;
  friendprofile({this.data});
  _friendprofileState createState() => _friendprofileState();
}

class _friendprofileState extends State<friendprofile> {

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  var _friendname;
  var _friendimageurl;
  var _friendid;

  var _userid;
  var _username;
  var _userimage;

  //.................PROFILE VARIABLE...............................

  int postcount = 0;
  int followercount = 0;
  int followingcount = 0;

  var status;
  var _about;
  var _followertext = 'FOLLOW';

  final storage = new FlutterSecureStorage();

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    // TODO: implement initState
    get_user_id();
    friendid();
    super.initState();
  }

  Future friendid() async{
    String friend_id = widget.data.friendId;
    String friend_image = widget.data.friendImg;
    String friend_name = widget.data.friendName;

    if(friend_id != null){

      //............................FOLLOWING COUNT OF USER.............................

      ref.child('user').child('$friend_id').child('following').once().then((DataSnapshot snap) async{
        var key = await snap.value.keys;
        setState(() {
          this.followingcount = key.length;
        });
      });

      //............................POST COUNT OF USER.............................

      ref.child('user').child('$friend_id').child('post').once().then((DataSnapshot snap) async{
        var key = await snap.value.keys;
        setState(() {
          this.postcount = key.length;
        });
      });

      //............................FOLLOWERS COUNT OF USER.............................

      ref.child('user').child('$friend_id').child('follower').once().then((DataSnapshot snap) async{
        var key = await snap.value.keys;
        setState(() {
          this.followercount = key.length;
        });
      });

      //.........................USER STATUS..........................................

      ref.child('user').child('$friend_id').child('status').once().then((DataSnapshot snap) async{
        var statusvalue = await snap.value;
        setState(() {
          status = statusvalue;
        });
      });

      //.........................USER ABOUT..........................................

      ref.child('user').child('$friend_id').child('about').once().then((DataSnapshot snap) async{
        var about = await snap.value;
        setState(() {
          _about = about;
        });
      });

      var newuserid = await storage.read(key: 'user-id');

      ref.child('user').child('$friend_id').child('follower').child('$newuserid').once().then((DataSnapshot snap) async{
        var data = await snap.value;
        if(data != null){
          setState((){
            _followertext = 'FOLLOWING';
          });
        }
      });
    }

    setState(() {
      _friendname = friend_name;
      _friendid = friend_id;
      _friendimageurl = friend_image;
    });
  }

  TextStyle textstyle = new TextStyle(
    color: Colors.white,
  );

  Future get_user_id() async{
    String userid = await storage.read(key:'user-id');
    String username = await storage.read(key:'user-name');
    String userimage = await storage.read(key:'user-image');
    setState((){
      this._userid = userid;
      this._username = username;
      this._userimage = userimage;
    });
  }

  _snackbar() {
    final snackbar = new SnackBar(
      content: new Text('STARTED FOLLOWING'),
      duration: new Duration(milliseconds: 2000),
      backgroundColor: Colors.green,
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }


  void changepage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => profile()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color.fromRGBO(64, 75, 96, .9),

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
      
       new Stack(
        children: <Widget>[
          Positioned(
            width: MediaQuery.of(context).size.width,
            top: 30.0,
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
                          image: CachedNetworkImageProvider(_friendimageurl),
                          fit: BoxFit.cover,
                        ),
                      borderRadius: BorderRadius.all(Radius.circular(75.0)),
                    ),
                  ),
                SizedBox(height: 10.0),
                Text(
                  '$_friendname',
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      color: Colors.blue  
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>friendfollower(data: widget.data.friendId)));
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>friendfollowing(data: widget.data.friendId)));
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
                        friendProfile fp = new friendProfile(widget.data.friendId, widget.data.friendName, widget.data.friendImg);
                        Navigator.push(context,MaterialPageRoute(builder: (context) => friendpost(data: fp)));
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

                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    new Container(
                      width: MediaQuery.of(context).size.width/2-50,
                      height: 40.0,
                      child: new InkWell(
                        onTap: () {
                          ref.child('user').child('$_userid').child('following').child('$_friendid').child('name').set('$_friendname');
                          ref.child('user').child('$_userid').child('following').child('$_friendid').child('image_url').set('$_friendimageurl');
                          ref.child('user').child('$_friendid').child('follower').child('$_userid').child('name').set('$_username');
                          ref.child('user').child('$_friendid').child('follower').child('$_userid').child('image_url').set('$_userimage');
                          _snackbar();
                        },
                        child: Material(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.redAccent,
                          shadowColor: Colors.redAccent.withOpacity(0.8),
                          elevation: 7.0,
                          child: Center(
                            child: new Text(
                              '$_followertext',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    new Padding(padding: new EdgeInsets.all(10.0),),

                    new Container(
                      width: MediaQuery.of(context).size.width/2-50,
                      height: 40.0,
                      child: InkWell(
                        onTap: (){
                          friendProfile fp = new friendProfile(
                            widget.data.friendId,
                            widget.data.friendName,
                            widget.data.friendImg
                          );
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>message_friend(data: fp)));
                        },
                        child: Material(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.redAccent,
                          shadowColor: Colors.redAccent.withOpacity(0.8),
                          elevation: 7.0,
                          child: Center(
                            child: new Text(
                              'MESSAGE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )

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
    );
  }
}

//end