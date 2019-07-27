import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/data/myFollower.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class followers extends StatefulWidget {
  @override
  _followersState createState() => _followersState();
}


class _followersState extends State<followers> {
  DatabaseReference ref = FirebaseDatabase.instance.reference();
  List<myFollower> allData = [];
  var _userid='';

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    get_user_id();
  }

  Future get_user_id() async{
    String user_id = await storage.read(key: 'user-id');
    print('ye chalega kya $user_id');

    setState(() {
        _userid = user_id;
    });

    if(user_id != null){
      await Future.delayed(Duration(milliseconds: 300),(){
      ref.child('user').child('$_userid').child('follower').once().then((DataSnapshot snap) async{
      var key = await snap.value.keys;
      var data = await snap.value;

      print('this is data $data');
      print('these are keys $key');

      for(var keys in key){
        myFollower myfollo = new myFollower(keys,data['$keys']['name'], data['$keys']['image_url']);
        allData.add(myfollo);
      }
      setState(() {
        
        });
      });

      });
    }
  }

  void delete_follow(var deletekey){
    ref.child('user').child('$_userid').child('follower').child('$deletekey').remove();
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context)=> followers()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                new Container(
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
                new Padding(
                  padding: new EdgeInsets.all(5.0),
                ),
                new Text('$name'),

                new IconButton(
                    icon: new Icon(Icons.cancel),
                    alignment: Alignment.bottomRight,
                    onPressed: (){
                      print('cancel is clicked $key');
                      delete_follow(key);
                  }
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