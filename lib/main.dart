import 'package:firebaseapp/components/login_button.dart';
import 'package:firebaseapp/homepage/allPostDataPage.dart';
// import 'package:firebaseapp/homepage/category.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebaseapp/splashscreen/splashscreen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'dart:convert' as JSON;
import 'package:http/http.dart' as http;
import 'components/buttonData.dart';

void main() => runApp(
      new MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        title: 'Post-it',
        theme: new ThemeData(primarySwatch: Colors.deepPurple),
        color: Colors.deepPurpleAccent,
      ),
    );

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  var _token;

  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  final storage = new FlutterSecureStorage();

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  buttonData buttonValue;

  //Google login
  //login proved us with username, imageurl, token and user id
  Future<FirebaseUser> _GooglesignIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );

    FirebaseUser googleuser =
        (await _fAuth.signInWithCredential(credential)).user;

    var displayname = googleuser.displayName;
    var photourl = googleuser.photoUrl;
    var userid = googleSignInAccount.id;
    var token = gSA.accessToken;

    store_user_detail(userid, photourl, displayname);

    store_token(token);
    read_token();

    ref.child('user').child(userid).once().then((DataSnapshot snap){
      var data = snap.value;
      if(data == null){
        ref.child('newuser').set(displayname);
        post_UserData(userid, displayname, photourl);
      }else{
        post_UserData(userid, displayname, photourl);
      }
    });
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => allPostDataPage()));
    return null;
  }

  //Facebook Login OAuth
  Future<FirebaseUser> _loginWithFB() async {
    FacebookLogin fbLogin = new FacebookLogin();

    // Open facebook page so that user can login
    final result = await fbLogin.logIn(['email', 'public_profile']);
    switch (result.status) {

      //If user successfully loggedin the user data will be returned
      case FacebookLoginStatus.loggedIn:

        //user token will be returned here
        final token = result.accessToken.token;


        //The returned token will be accessed here to get the user data into json format
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');

        //The json will be decoded here
        final profile = JSON.jsonDecode(graphResponse.body);
        var userid = profile['id'];
        var username = profile['name'];
        var userimage = profile['picture']['data']['url'];

        store_user_detail(userid, userimage, username);
        store_token(token);
        read_token();

        ref.child('user').child(userid).once().then((DataSnapshot snap){
          var data = snap.value;
          if(data == null){
            ref.child('newuser').set(username);
            post_UserData(userid, username, userimage);
          }
          else{
            post_UserData(userid, username, userimage);
          }
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => allPostDataPage()));
        break;
    }
  }

  void post_UserData(var userid, var username, var userimage){
    ref.child('user').child(userid).child('imageurl').set(userimage);
    ref.child('user').child(userid).child('name').set(username);
    FCM_token(userid);
  }

  Future store_token(String valid_token) async {
    await storage.write(key: 'valid_token', value: '$valid_token');
  }

  @override
  void initState() {
    // TODO: implement initStat
    read_token();
    super.initState();
  }

  //creating session which will store the token of the user and check whether the token is present or not
  // If token is present it will redirect to the homepage otherwise landing / login page
  Future read_token() async {
    String value = await storage.read(key: 'valid_token');
    if (value != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => allPostDataPage()));
    }
  }

  FCM_token(var userid) {
    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        print(" onMessage called ${(msg)}");
      },
    );

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    firebaseMessaging.getToken().then((token) {
      ref.child('fcm-token').child(token).child('token').set(token);
      ref.child('user').child(userid).child('fcm-token').set(token);
    });
  }

  Future store_user_detail(String userid, userimage, username) async {
    await storage.write(key: 'user-id', value: '$userid');
    await storage.write(key: 'user-image', value: '$userimage');
    await storage.write(key: 'user-name', value: '$username');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.purple[200],
        body: Center(
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: new Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(top: 60),
                  ),
                  new Image(
                    image: AssetImage('asset/mainlogo.png'),
                  ),
                  loginButton(data: buttonValue = new buttonData('Google', Colors.redAccent, LineIcons.google, _GooglesignIn)),
                  new Padding(
                    padding: new EdgeInsets.all(8.0),
                  ),
                  loginButton(data: buttonValue = new buttonData('Facebook', Colors.blue, LineIcons.facebook, _loginWithFB)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//end
