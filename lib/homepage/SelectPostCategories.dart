import 'package:firebaseapp/homepage/ShowDataPage.dart';
import 'package:firebaseapp/homepage/allPostDataPage.dart';
import 'package:flutter/material.dart';
import 'package:firebaseapp/data/SubmitFormData.dart';
import 'package:firebase_database/firebase_database.dart';
class selectPostCategories extends StatefulWidget {
  final SendFormData data;
  selectPostCategories({this.data});
  @override
  _selectPostCategoriesState createState() => _selectPostCategoriesState();
}

class _selectPostCategoriesState extends State<selectPostCategories> {
  List listCategories = [
    "Politics",
    "Spiritual",
    "Cooking",
    "Lifestyle",
    "Entertainment",
    "News",
    "Global",
    "Desi",
    "Friends",
    "Health",
    "Work",
    "Music",
    "Education",
    "Positive",
    "Gaming",
  ];

  List listCategoriesColor = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
  ];

  List selectedCategories = [];

  static DatabaseReference ref = FirebaseDatabase.instance.reference();
  var time, userid, newname, message, date, newurl, newemail;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData(){
    time = this.widget.data.time;
    newname = this.widget.data.newname;
    message = this.widget.data.message;
    date = this.widget.data.date;
    newurl = this.widget.data.newurl;
    newemail = this.widget.data.newemail;
    userid = this.widget.data.userid;
    setState(() {
      
    });
  }

  submitNodeNameData(){
    ref.child('node-name').child('$time').child('name').set('$newname');
    ref.child('node-name').child('$time').child('message').set('$message');
    ref.child('node-name').child('$time').child('msgtime').set('$date');
    ref.child('node-name').child('$time').child('image').set('$newurl');
    ref.child('node-name').child('$time').child('email').set('$newemail');
    ref.child('node-name').child('$time').child('userid').set('$userid');
    ref.child('node-name').child('$time').child('comments').child('no-comments').set('1');
    ref.child('node-name').child('$time').child('likes').child('no-likes').set('1');

    ref.child('user').child('$userid').child('post').child('$time').child('message').set('$message');
    ref.child('user').child('$userid').child('post').child('$time').child('msgtime').set('$date');
    ref.child('user').child('$userid').child('name').set('$newname');
    ref.child('user').child('$userid').child('imageurl').set('$newurl');
    ref.child('user').child('$userid').child('lastPostTimestamp').set('$time');
  }

  submitmessage(var categorySelected, int index) async{    
    ref.child("category").child('$categorySelected').child('$time').child('name').set('$newname');
    ref.child("category").child('$categorySelected').child('$time').child('message').set('$message');
    ref.child("category").child('$categorySelected').child('$time').child('msgtime').set('$date');
    ref.child("category").child('$categorySelected').child('$time').child('image').set('$newurl');
    ref.child("category").child('$categorySelected').child('$time').child('email').set('$newemail');
    ref.child("category").child('$categorySelected').child('$time').child('userid').set('$userid');
    ref.child("category").child('$categorySelected').child('$time').child('comments').child('no-comments').set('1');
    ref.child("category").child('$categorySelected').child('$time').child('likes').child('no-likes').set('1');

    ref.child('node-name').child('$time').child('category').child('$index').set('${selectedCategories[index]}');
  }

  sendDataByCategories(){
    submitNodeNameData();
    int index = 0;
    for(var data in selectedCategories){
      submitmessage(data, index++);
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>allPostDataPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Select Categories"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      floatingActionButton: selectedCategories.length!=0 ? new FloatingActionButton(
        onPressed: sendDataByCategories,
        child: new Icon(Icons.send),
      ): new Container(),
      body: new Container(
        child: new ListView.builder(
          itemBuilder: (_, index) {
            return categoriesWidget(index);
          },
          itemCount: listCategories.length,
        ),
      ),
    );
  }

  Widget categoriesWidget(int value) {
    return Padding(
      padding: new EdgeInsets.all(10.0),
      child: Center(
        child: InkWell(
          onTap: (){
            if(!selectedCategories.contains(listCategories[value]) && selectedCategories.length<3){
              selectedCategories.add(listCategories[value]);
              listCategoriesColor[value] = Colors.green;
            }else{
              selectedCategories.remove(listCategories[value]);
              listCategoriesColor[value] = Colors.black;
            }
            setState((){});
          },
          child: new Text(
            listCategories[value].toString(),
            style: new TextStyle(color: listCategoriesColor[value],fontSize: 25,fontWeight: FontWeight.w300,),
          ),
        ),
      ),
    );
  }
}
