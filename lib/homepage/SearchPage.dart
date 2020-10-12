import 'package:firebaseapp/friend/friendprofile.dart';
import 'package:firebaseapp/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/data/friendProfile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class searchPage extends StatefulWidget {
  @override
  _searchPageState createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  DatabaseReference db = FirebaseDatabase.instance.reference();

  List<friendProfile> list = [];
  List<friendProfile> searchList = [];
  var _realuser;

  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    get_real_user_data();
    database_UserData();
    super.initState();
  }

  database_UserData() {
    db.child('user').once().then((DataSnapshot snap) {
      var newkey = snap.value.keys;
      var snapData = snap.value;
      for (var x in newkey) {
        if (snapData[x]['name'] != null) {
          friendProfile data = new friendProfile(
              x, snapData[x]['name'], snapData[x]['imageurl']);
          list.add(data);
        }
      }
      setState(() {});
    });
  }

  Future get_real_user_data() async {
    final storage = new FlutterSecureStorage();
    var real_user = await storage.read(key: 'user-id');
    setState(() {
      _realuser = real_user;
    });
  }

  searchFunction() {
    searchList.clear();
    for (friendProfile data in list) {
      if (data.friendName
          .toString()
          .toLowerCase()
          .contains(searchController.text.toLowerCase())) {
        setState(() {
          searchList.add(data);
        });
      }
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.deepPurpleAccent,
          ),
          new Container(
            color: Colors.deepPurpleAccent,
            width: MediaQuery.of(context).size.width,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 40.0,
                  child: new TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: searchController,
                    style: new TextStyle(
                      fontSize: 18.0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    ),
                  ),
                ),
                new IconButton(
                  icon: new Icon(
                    Icons.search,
                    size: 30.0,
                  ),
                  onPressed: searchFunction,
                )
              ],
            ),
          ),
          new Expanded(
            child: MediaQuery.removePadding(
              removeTop: true,
              context: (context),
              child: new ListView.builder(
                shrinkWrap: true,
                itemCount: searchList.length,
                itemBuilder: (_, i) {
                  return UIFollower(searchList[i].friendId,
                      searchList[i].friendName, searchList[i].friendImg);
                },
              ),
            ),
          ),
        ],
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
                    onTap: () async {
                      if (key != _realuser) {
                        friendProfile fp =
                            new friendProfile(key, name, image_url);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => friendprofile(data: fp)));
                      } else if (key == _realuser) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => profile()));
                      }
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
