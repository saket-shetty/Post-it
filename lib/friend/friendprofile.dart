import 'package:flutter/material.dart';
import 'package:firebaseapp/user/profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/friend/friendpost.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class friendprofile extends StatefulWidget {
  @override
  _friendprofileState createState() => _friendprofileState();
}

class _friendprofileState extends State<friendprofile> {

  var _friendname;
  var _friendimageurl;
  var _friendid;
  var _userid;
  var _username;
  var _userimage;

  final storage = new FlutterSecureStorage();

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    // TODO: implement initState
    friendid();
    get_user_id();
    super.initState();
  }

  Future friendid() async{
    String friend_id = await storage.read(key: 'friend-id');
    String friend_image = await storage.read(key: 'friend-image');
    String friend_name = await storage.read(key: 'friend-name');

    setState(() {
      _friendname = friend_name;
      _friendid = friend_id;
      _friendimageurl = friend_image;
    });
    // print('friend ka id hai :$value');
  }

  Future get_user_id() async{
    String userid = await storage.read(key:'user-id');
    String username = await storage.read(key:'user-name');
    String userimage = await storage.read(key:'user-image');
    setState((){
      _userid = userid;
      _username = username;
      _userimage = userimage;
    });
  }


  void changepage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => profile()));
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: _friendname == null
          ? new Center(
              child: FlareActor(
                'asset/linear.flr',
                animation: 'linear',
                fit: BoxFit.contain,
              ),
            )
          : new Stack(
              children: <Widget>[
                ClipPath(
                  child: Container(color: Colors.black.withOpacity(0.8)),
                  clipper: getClipper(),
                ),
                Positioned(
                  width: 350.0,
                  top: MediaQuery.of(context).size.height / 5,
                  child: Column(
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            child: new Icon(
                              Icons.person_add,
                              size: 30.0,
                              color: Colors.black,
                            ),
                            onTap: (){
                              print('friend added');
                              print('real user id $_userid');
                              print('friend user id $_friendid');
                              ref.child('user').child('$_userid').child('following').child('$_friendid').child('name').set('$_friendname');
                              ref.child('user').child('$_userid').child('following').child('$_friendid').child('image_url').set('$_friendimageurl');
                              ref.child('user').child('$_friendid').child('follower').child('$_userid').child('name').set('$_username');
                              ref.child('user').child('$_friendid').child('follower').child('$_userid').child('image_url').set('$_userimage');
                            },
                          )
                        ],
                      ),
                     Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              image: DecorationImage(
                                  image: NetworkImage(_friendimageurl),
                                  fit: BoxFit.cover),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(75.0)),
                              boxShadow: [
                                BoxShadow(blurRadius: 7.0, color: Colors.black)
                              ])),
                      SizedBox(height: 30.0),
                      Text(
                        '$_friendname',
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat'),
                      ),
                      SizedBox(height: 15.0),
                      Text(
                        'STATUS',
                        style: TextStyle(
                            fontSize: 17.0,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Montserrat'),
                      ),
                      SizedBox(height: 25.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => friendpost()));
                        },
                        child: Container(
                            height: 40.0,
                            width: 105.0,
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              shadowColor: Colors.greenAccent,
                              color: Colors.green,
                              elevation: 7.0,
                              child: Center(
                                child: Text(
                                  'POSTS',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat'),
                                ),
                              ),
                            )),
                      ),
                      SizedBox(height: 25.0),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}



class getClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0.0, size.height/2);
    path.lineTo(size.width + 125, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
//end