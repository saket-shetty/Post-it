import 'package:firebaseapp/data/friendProfile.dart';
import 'package:firebaseapp/friend/message_friend.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class message_page extends StatefulWidget {
  @override
  _message_pageState createState() => _message_pageState();
}

class _message_pageState extends State<message_page> {

  List <message_page_data> allData = [];

  var _userid;

  final storage = new FlutterSecureStorage();

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    // TODO: implement initState
    get_user_data();
    super.initState();
  }

  Future get_user_data() async{
    var userid = await storage.read(key: 'user-id');
    ref.child('user').child('$userid').child('message').once().then((DataSnapshot snap){
      var parentkey = snap.value.keys;

      for(var key in parentkey){
        ref.child('user').child('$userid').child('message').child('${key.toString()}').limitToLast(1).once().then((DataSnapshot snap){
          
          var childkey = snap.value.keys;
          var childdata = snap.value;

          for(var x in childkey){
            message_page_data data = new message_page_data(childdata[x]['friend-name'], childdata[x]['friend-image'],
             childdata[x]['message'], childdata[x]['time'], '$key');
             allData.add(data);
          }

          setState(() {
            
          });

        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('MESSAGE',
          style: new TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),

      body: allData.length == 0 ? new Text('Wait a minute') :
    
      new ListView.builder(
        itemCount: allData.length,
        itemBuilder: (_,index){
          return messageUI(
            allData[index].name,
            allData[index].image,
            allData[index].message,
            allData[index].time,
            allData[index].friendid
          );
        },
      ),
    );
  }

  Widget messageUI(var name, var image, var message, var time, var friendid){
  return GestureDetector(
    onTap: () async{
      friendProfile fp = new friendProfile(friendid, name, image);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>message_friend(data: fp)));
      },
        child: Column(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(top: 5.0),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(left: 10.0),
              ),
              new Container(
                width: 50,
                height: 50,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage('$image'),
                  ),
                ),
              ),
              new Padding(
                padding: new EdgeInsets.only(left: 15.0),
              ),
              Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      '$message',
                      maxLines: 2,
                      style: new TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(bottom: 5.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(
                          '$name',
                          style: new TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: new Text('$time',
                              style: new TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          new Divider(
            color: Colors.black,
          )
        ],
      ),
    );
  }
}



class message_page_data{
  var name;
  var image;
  var message;
  var time;
  var friendid;
  message_page_data(this.name, this.image, this.message, this.time, this.friendid);
}