import 'package:firebaseapp/data/userData.dart';
import 'package:firebaseapp/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class editProfile extends StatefulWidget {
  @override
  final userData data;
  editProfile({this.data});
  _editProfileState createState() => _editProfileState();
}

class _editProfileState extends State<editProfile> {

  TextEditingController _name, _status, _about;

  DatabaseReference ref =  FirebaseDatabase.instance.reference();

  void onSubmit(var _newName, var _newStatus, var _newAbout){
    ref.child('user').child(widget.data.userid).child('name').set(_newName);
    ref.child('user').child(widget.data.userid).child('status').set(_newStatus);
    ref.child('user').child(widget.data.userid).child('about').set(_newAbout);
  }

  @override
  void initState() {
    // TODO: implement initState

    _name = new TextEditingController(text: widget.data.name);
    _status = new TextEditingController(text: widget.data.status);
    _about = new TextEditingController(text: widget.data.about);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,

      //App bar of the contact page

      appBar: new AppBar(
        title: new Text(
          'Edit Profile',
          style: new TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),

      // Body of the contact page

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 8.0),

                new Text(
                  'Edit your name',
                  style: new TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),

                // Textfield of the email which will be autofill

                new TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _name,
                  decoration: InputDecoration(
                    hintText: 'edit name',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                  ),
                ),
                SizedBox(height: 8.0),

                // Textfield of the subject

                new Text(
                  'Edit your status',
                  style: new TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),

                new TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _status,
                  decoration: InputDecoration(
                    hintText: 'edit status',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                  ),
                ),
                SizedBox(height: 8.0),
                new Text(
                  'Edit your about',
                  style: new TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),

                // Textfield of the message

                new TextFormField(
                  controller: _about,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    labelText: "Enter Message",
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                  ),
                ),
                SizedBox(height: 8.0),

                // Submit button which will take all the data from the text controller
                // Button will not worl since there is no ontap function is given to it
                // Future: using GestureDetection or InkWell and onTap:

                InkWell(
                  onTap: (){
                    onSubmit(_name.text, _status.text, _about.text);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>profile()));
                  },
                  child: new Center(
                    child: new Container(
                      width: 120,
                      height: 50,
                      child: Center(
                        child: new Text(
                          'Submit',
                          style:
                              new TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                      ),
                      decoration: new BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: new BorderRadius.circular(25.0)),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
