import 'package:flutter/material.dart';
import 'package:firebaseapp/homepage/ShowDataPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebaseapp/splashscreen/splashscreen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  //Remember to remove both key
  //you have to fill the form to get api and secret key 
  //contact me if you want the key to check the functionality      
  static final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: 'MwJtsArQqT1ZPnnzLabe8MEpZ',
    consumerSecret: 'keeq4dUYRE9UkitnI1n4JNesAuicgShqgxQ9UCSfVG4xoT7R9e',
  );
  
  //Google login
  //login proved us with username, imageurl, token and user id
  Future<FirebaseUser> _GooglesignIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );

    FirebaseUser googleuser = (await _fAuth.signInWithCredential(credential)).user;
        
    var displayname = googleuser.displayName;
    var photourl = googleuser.photoUrl;
    var useremail = googleuser.email;
    var userid = googleSignInAccount.id;
    var token = gSA.accessToken;

    store_user_detail(userid,photourl,displayname);
    store_token(token);
    read_token();
    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowDataPage()));

    print('is this gsa :$gSA');
    print('is this token :${gSA.idToken}');
    print('is this accesstoken :${gSA.accessToken}');
    print('is this proverid :${googleuser.providerId}');
    print('googlesigninaccount id :${googleSignInAccount.id}');

    ref.child('user').child(userid).child('imageurl').set(photourl);
    ref.child('user').child(userid).child('name').set(displayname);

    return null;
  }


  Future store_token(String valid_token) async{
    await storage.write(key: 'valid_token', value: '$valid_token');
  }

  // Twitter Login
  // Remember to remove secret key and api key before uploading to github
  // Twitter doesnt provide the user image url so i am using a default image which will be same for every user.

  void _Twitterlogin() async {
    final TwitterLoginResult result = await twitterLogin.authorize();
    var session = result.session;
    final AuthCredential credential = TwitterAuthProvider.getCredential(
      authToken: session.token,
      authTokenSecret: result.session.secret,
    );

    FirebaseUser user = (await _fAuth.signInWithCredential(credential)).user;

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        var name = result.session.username;
        var image =
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRi-I5E9Vn6dFsuJnrJfJVcpNp6KNQ74ZSjKoGn5t9-pGLddxDG';
        var userid = result.session.userId;
        var accesstoken = result.session.token;
        print('twitter name :${result.session.username}');
        print('twitter name :${result.session.userId}');
        print('${result.session.token}');
        
        store_user_detail(userid,image,name);
        store_token(accesstoken);
        read_token();

        ref.child('user').child(userid).child('imageurl').set(image);
        ref.child('user').child(userid).child('name').set(name);



        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ShowDataPage()));
        break;
      case TwitterLoginStatus.cancelledByUser:
        break;
      case TwitterLoginStatus.error:
        break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    read_token();


    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        
        // showNotification(msg);

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
      fcm_token(token);
    });
    super.initState();
  }

  fcm_token(var token){
      print('this is token $token');
      ref.child('fcm-token').child(token).child('token').set(token);
  }

  //creating session which will store the token of the user and check whether the token is present or not
  // If token is present it will redirect to the homepage otherwise landing / login page
  Future read_token() async{
    String value = await storage.read(key: 'valid_token');

    if(value != null){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowDataPage()));
    }

    print("this is the token value from secure token :$value");
  }


  Future store_user_detail(String userid, userimage, username) async{
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
    return
    WillPopScope(
      onWillPop: () async=> false,
      child: Scaffold(
        backgroundColor: Colors.red[100],
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
                  new Container(
                    width: 180,
                    height: 50.0,
                    child: new InkWell(
                      onTap: () {
                        _GooglesignIn();
                      },
                      child: Material(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.redAccent,
                        shadowColor: Colors.redAccent.withOpacity(0.8),
                        elevation: 7.0,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Icon(
                                LineIcons.google,
                                size: 25.0,
                                color: Colors.white,
                              ),
                              new VerticalDivider(
                                color: Colors.black,
                                width: 22.0,
                              ),
                              new Text(
                                'Google',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  new Padding(
                    padding: new EdgeInsets.all(8.0),
                  ),

                  new Container(
                    width: 180,
                    height: 50.0,
                    child: new InkWell(
                      onTap: () {
                        _Twitterlogin();
                      },
                      child: Material(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.lightBlue,
                        shadowColor: Colors.lightBlue.withOpacity(0.8),
                        elevation: 7.0,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Icon(
                                LineIcons.twitter,
                                size: 25.0,
                                color: Colors.white,
                              ),
                              new VerticalDivider(
                                color: Colors.black,
                                width: 22.0,
                              ),
                              new Text(
                                'Twitter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  new Padding(
                    padding: new EdgeInsets.all(8.0),
                  ),
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