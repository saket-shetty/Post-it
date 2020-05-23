import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/homepage/ShowDataPage.dart';
import 'package:time_machine/time_machine.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebaseapp/components/login_button.dart';
import 'package:firebaseapp/components/buttonData.dart';
import 'package:line_icons/line_icons.dart';

class SubmitForm extends StatefulWidget {
  @override
  _SubmitFormState createState() => new _SubmitFormState();
}


class _SubmitFormState extends State<SubmitForm> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  String _newname, _newurl, _newemail, _userid;

  static DatabaseReference ref = FirebaseDatabase.instance.reference();
  String _message;
  var report_status;
  int reportcount = 0;

  final storage = new FlutterSecureStorage();

  buttonData btnData;

  @override
  void initState() {
    // TODO: implement initState
    get_user_detail();
    get_report_status();
    super.initState();
  }

  Future get_user_detail() async{
    String userid = await storage.read(key: 'user-id');
    String username = await storage.read(key: 'user-name');
    String userimage = await storage.read(key: 'user-image');

    setState(() {
     _newname = username;
     _newurl = userimage;
     _userid = userid;
    });
  }

  Future get_report_status() async{
    report_status = await storage.read(key: 'report-status');
    
    setState(() {
      
    });
  }

  void _submit() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      submitmessage();
    }
  }

  void submitmessage() {
    var now = Instant.now();
    var time = now.toString('yyyyMMddHHmmss');

    var date_day = new DateTime.now().day;
    var date_month = new DateTime.now().month;
    var date_year = new DateTime.now().year;

    String date = date_day.toString() +
        ':' +
        date_month.toString() +
        ':' +
        date_year.toString();

    if (_newname.isNotEmpty && _message.isNotEmpty != null && report_status != 'true') {
      ref.child('node-name').child('$time').child('name').set('$_newname');
      ref.child('node-name').child('$time').child('message').set('$_message');
      ref.child('node-name').child('$time').child('msgtime').set('$date');
      ref.child('node-name').child('$time').child('image').set('$_newurl');
      ref.child('node-name').child('$time').child('email').set('$_newemail');
      ref.child('node-name').child('$time').child('userid').set('$_userid');
      ref.child('node-name').child('$time').child('comments').child('no-comments').set('1');
      ref.child('node-name').child('$time').child('likes').child('no-likes').set('1');
      ref.child('user').child('$_userid').child('post').child('$time').child('message').set('$_message');
      ref.child('user').child('$_userid').child('post').child('$time').child('msgtime').set('$date');
      ref.child('user').child('$_userid').child('name').set('$_newname');
      ref.child('user').child('$_userid').child('imageurl').set('$_newurl');
      ref.child('notification').child('name').set('$_newname');
      ref.child('notification').child('message').set('$_message');

      Navigator.of(context).pop();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ShowDataPage()));
    } else if (report_status == 'true') {
      _snackbar();
    }
  }

  _snackbar() {
    final snackbar = new SnackBar(
      content: new Text('You have been reported'),
      duration: new Duration(milliseconds: 2000),
      backgroundColor: Colors.red,
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    final double deviceheight = MediaQuery.of(context).size.height;
    final double keyboardheight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        title: Text(
          'New Post',
          style: TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: new Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
        child: new Form(
          key: formKey,
          child: new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Text(
                    '$_newname',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              new Container(
                height: deviceheight - keyboardheight - 200,
                child: TextFormField(
                  cursorColor: Colors.deepPurpleAccent,
                  autocorrect: true,
                  scrollPadding: const EdgeInsets.all(20.0),
                  style: TextStyle(fontSize: 22.0, color: Colors.black),
                  autofocus: true,
                  decoration: new InputDecoration(errorMaxLines: 3),
                  maxLines: 20,
                  keyboardType: TextInputType.multiline,
                  validator: (val) =>
                      val.length < 1 ? 'please enter message' : null,
                  onSaved: (val) => _message = val,
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 26.0),
              ),
              loginButton(data: btnData = new buttonData('Submit', Colors.deepPurpleAccent, LineIcons.pencil, _submit)),
            ],
          ),
        ),
      ),
    );
  }
}
//end