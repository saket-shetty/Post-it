import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class setting extends StatefulWidget {
  @override
  _settingState createState() => _settingState();
}

class _settingState extends State<setting> {

  TextEditingController _status = new TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final storage = new FlutterSecureStorage();

  var _username, _userstatus, _userabout, _userimage;

  Future get_user_detail() async{
    _username = await storage.read(key: 'user-name');
    _userimage = await storage.read(key: 'user-image');
    setState(() {
      
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    get_user_detail();
    super.initState();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        title: new Text(
          'Setting',
          style: new TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),

      body: Expanded(
        child: Center(
          child: new Column(
            children: <Widget>[
              Container(
                width: 150.0,
                height: 150.0,
                decoration: BoxDecoration(
                  color: Colors.red,
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(_userimage),
                      fit: BoxFit.cover,),
                  borderRadius: BorderRadius.all(Radius.circular(75.0)),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                '$_username',
                style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: Colors.blue  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//end