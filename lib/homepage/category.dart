import 'package:firebaseapp/homepage/CategoryPost.dart';
import 'package:firebaseapp/homepage/ShowDataPage.dart';
import 'package:firebaseapp/homepage/allPostDataPage.dart';
import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  List listCategories = [
    "Show All",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Trending Category",
          style: new TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
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
          onTap: () {
            if(value==0){
              Navigator.push((context), new MaterialPageRoute(builder: (context)=>allPostDataPage()));
            }else{
              Navigator.push((context), new MaterialPageRoute(builder: (context)=>CategoryPost(data: listCategories[value])));
            }
          },
          child: new Text(
            listCategories[value].toString(),
            style: new TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
