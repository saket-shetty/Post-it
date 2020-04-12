import 'package:firebaseapp/friend/friendprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/data/myFollowing.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebaseapp/data/friendProfile.dart';


class following extends StatefulWidget {
  @override
  _followingState createState() => _followingState();
}


class _followingState extends State<following> {
  DatabaseReference ref = FirebaseDatabase.instance.reference();
  List<myFollowing> allData = [];
  var _userid='';

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    get_user_id();
  }

  Future get_user_id() async{
    String user_id = await storage.read(key: 'user-id');

    setState(() {
        _userid = user_id;
    });

    if(user_id != null){
      await Future.delayed(Duration(milliseconds: 300),(){
      ref.child('user').child('$_userid').child('following').once().then((DataSnapshot snap) async{
      var key = await snap.value.keys;
      var data = await snap.value;

      for(var keys in key){
        myFollowing myfollo = new myFollowing(keys,data['$keys']['name'], data['$keys']['image_url']);
        allData.add(myfollo);
      }
      setState(() {
        
        });
      });

      });
    }
  }

  void delete_follow(var deletekey){
    ref.child('user').child('$_userid').child('following').child('$deletekey').remove();
    ref.child('user').child('$deletekey').child('follower').child('$_userid').remove();
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context)=> following()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(64, 75, 96, .9),
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('Following'),
      ),
      body: new Container(
        child: allData.length == 0
            ? new Text('no data found')
            : new ListView.builder(
                itemCount: allData.length,
                itemBuilder: (_, index) {
                  return UIFollower(
                      allData[index].key,
                      allData[index].name, 
                      allData[index].image_url
                      );
                }),
      ),
    );
  }

  Widget UIFollower(var key, String name, String image_url) {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Row(
                children: <Widget>[
                  
                  GestureDetector(
                    onTap: ()async{
                      // await storage.write(key: 'friend-id', value: '$key');
                      // await storage.write(key: 'friend-name', value: '$name');
                      // await storage.write(key: 'friend-image', value: '$image_url');

                      final friendProfile fp = new friendProfile(
                        key,
                        name,
                        image_url
                      );

                      Navigator.push(context, MaterialPageRoute(builder: (context)=>friendprofile(data: fp)));
                    },
                    child: new Container(
                      width: 55,
                      height: 55,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage('$image_url'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),

                  new Padding(
                    padding: new EdgeInsets.all(5.0),
                  ),

                  new Text('$name'),
                
                  Expanded(
                    child: new IconButton(
                      icon: new Icon(Icons.cancel),
                      alignment: Alignment.bottomRight,
                      onPressed: (){
                        delete_follow(key);
                    }
                  ),
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//end