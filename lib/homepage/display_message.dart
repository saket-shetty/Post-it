import 'package:firebaseapp/data/friendProfile.dart';
import 'package:firebaseapp/friend/friendprofile.dart';
import 'package:firebaseapp/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/data/myComment.dart';
import 'package:time_machine/time_machine.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebaseapp/data/sendMessageData.dart';

class displaymessage extends StatefulWidget {
  @override
  final sendMessageData data;
  displaymessage({this.data});
  _displaymessageState createState() => _displaymessageState();
}


class _displaymessageState extends State<displaymessage> {
  bool display_textbox = false;
  bool _display_comment = false;

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  final store = new FlutterSecureStorage();


  List<myComment> allData = [];

  var _newname = '';
  var _newurl = '';
  var _newmessage = '';
  var _newmessagetimestamp = '';
  var _sendername = '';
  var _senderimageurl = '';
  var _message;
  var _userid;

  final formKey = new GlobalKey<FormState>();

  List commentlist = [];

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  Future post_data() async{
    String newname = widget.data.messagename;
    String newurl = widget.data.messageimg;
    String message = widget.data.message;
    String timestamp = widget.data.timestamp;

    String sendername = await store.read(key: 'user-name');
    String senderimage = await store.read(key: 'user-image');
    String userid = await store.read(key: 'user-id');

    setState((){
      this._newname = newname;
      this._newurl = newurl;
      this._newmessage = message;
      this._newmessagetimestamp = timestamp;
      this._sendername = sendername;
      this._senderimageurl = senderimage;
      this._userid = userid;
    });

  }


  @override
  void initState() {
    // TODO: implement initState
    post_data();
    _comments();
    setState(() {});
    super.initState();
  }

  Future _comments() async {
    await new Future.delayed(Duration(milliseconds: 150),() async{
      await ref.child('node-name').child('${widget.data.timestamp}').child('comments').once().then((DataSnapshot snap) {
          var keys = snap.value.keys;
          var data = snap.value;

          for (var key in keys) {
            if (key != 'no-comments') {
              commentlist.add(key);
              commentlist.sort();
            } else if (key == 'no-comments') {
            }
          }
          
          for (var newlist in commentlist) {
            myComment d = new myComment(
              data[newlist]['name'],
              data[newlist]['comment'],
              data[newlist]['image_url'],
              data[newlist]['id'],
              data[newlist]['time']
            );
            allData.add(d);
          }
        },
      );
      setState((){});
    });
  }


  void submit_comment() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      submit_comment_database();
    }
  }

  void submit_comment_database() {
    var now = Instant.now();
    var timestamp = now.toString('yyyyMMddHHmmss');

    var time = DateTime.now();
    int hour;
    var state;

    if(time.hour > 12){
      hour = time.hour - 12;
      state = 'pm';
      setState(() {});
    }
    else{
      hour = time.hour;
      state = 'am';
      setState(() {});
    }

    var currentime = hour.toString()+":"+time.minute.toString()+' '+state;

    ref.child('node-name').child('$_newmessagetimestamp').child('comments').child('$timestamp').child('comment').set('$_message');
    ref.child('node-name').child('$_newmessagetimestamp').child('comments').child('$timestamp').child('image_url').set('$_senderimageurl');
    ref.child('node-name').child('$_newmessagetimestamp').child('comments').child('$timestamp').child('name').set('$_sendername');
    ref.child('node-name').child('$_newmessagetimestamp').child('comments').child('$timestamp').child('id').set('$_userid');
    ref.child('node-name').child('$_newmessagetimestamp').child('comments').child('$timestamp').child('time').set('$currentime');
    ref.child('node-name').child('$_newmessagetimestamp').child('comments').child('$timestamp').child('postid').set('${widget.data.userid}');
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var toppadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color.fromRGBO(64, 75, 96, .9),
      body: new Column(
        children: <Widget>[
          new Container(
            color: Colors.deepPurpleAccent,
            padding: new EdgeInsets.only(top: toppadding),
            child: Column(
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.all(5.0),
                  color: Colors.deepPurple,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                        child: new Container(
                          width: 45.0,
                          height: 45.0,
                          //margin: EdgeInsets.only(top: 30.0),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(_newurl),
                            ),
                          ),
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      new Text(
                        '$_newname',
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w300,
                        ),
                      )
                    ],
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.all(25.0),
                ),
                new Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: new Center(
                    child: new Text(
                      '$_newmessage',
                      maxLines: 10,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.only(
                      left: 7.0, right: 7.0, bottom: 7.0, top: 25.0),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          new GestureDetector(
                            onTap: () {
                              // Update -> like message and display total count of like in profile
                            },
                            child: new Icon(
                              Icons.thumb_up,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                          new Padding(
                            padding: new EdgeInsets.only(right: 3.0),
                          ),
                          new Text(
                            '${widget.data.likecount}',
                            style: new TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new GestureDetector(
                            onTap: () {
                              var time = new DateTime.now();
                            },
                            child: new Icon(
                              Icons.chat_bubble_outline,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                          new Text(
                            '${widget.data.commentcount}',
                            style: new TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      new GestureDetector(
                        onTap: () {
                          // Update -> Add new functionality
                        },
                        child: new Icon(
                          Icons.star_border,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.all(10.0),
                )
              ],
            ),
          ),
          new Expanded(
            child: allData.length == 0
                ? new Center(
                    child: new Container(
                      child: Center(
                        child: new Text('be first one to comment'),
                      ),
                      width: 200,
                      height: 50,
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.orangeAccent,
                      ),
                    ),
                  )
                : new ListView.builder(
                    itemCount: allData.length,
                    itemBuilder: (_, index) {
                      return commentUI(
                        allData[index].name,
                        allData[index].image_url,
                        allData[index].comment,
                        allData[index].id,
                        allData[index].time
                      );
                    },
                  ),
          ),
          display_textbox == false
              ? new Container(
                  color: Colors.deepPurpleAccent,
                  child: Padding(
                    padding: EdgeInsets.all(05.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new GestureDetector(
                          onTap: () {
                            display_textbox = true;
                            setState(() {});
                          },
                          child: new Container(
                            width: 30,
                            height: 30,
                            decoration: new BoxDecoration(
                              borderRadius: new BorderRadius.circular(50.0),
                              color: Colors.orangeAccent,
                            ),
                            child: new Center(
                              child: new Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : new Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(
                      padding: new EdgeInsets.only(left: 5.0),
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(bottom: 3.0, top: 3.0),
                      child: new Container(
                        width: (size - 50),
                        height: 40.0,
                      
                        child: new Form(
                          key: formKey,
                          child: Padding(
                            padding: new EdgeInsets.only(left: 0.0),
                            child: Center(
                              child: new TextFormField(
                                maxLines: 3,
                                cursorColor: Colors.deepPurpleAccent,
                                
                                autofocus: true,
                                decoration: new InputDecoration(
                                  hintText: 'Write a Comment',
                                  contentPadding: EdgeInsets.fromLTRB(20.0,5.0, 20.0, 13.0),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                                  hintStyle: new TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                
                                validator: (val) => val.length < 1
                                    ? 'please enter message'
                                    : null,
                                style: new TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                                onSaved: (val) => _message = val,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    new Padding(padding: new EdgeInsets.all(1.0)),
                    new GestureDetector(
                      onTap: () {
                        submit_comment();
                        display_textbox = false;
                        Navigator.pop(context,MaterialPageRoute(builder: (context) => displaymessage()));
                        sendMessageData newdata = new sendMessageData(widget.data.messagename,
                          widget.data.messageimg,
                          widget.data.message,
                          widget.data.timestamp,
                          widget.data.userid,
                          widget.data.likecount,
                          widget.data.commentcount+1
                        );
                        Navigator.push(context,MaterialPageRoute(builder: (context) => displaymessage(data: newdata)));
                        setState(
                          () {

                          },
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(50.0),
                          color: Colors.deepPurpleAccent,
                        ),
                        child: Center(
                          child: new Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(bottom: 05.0),
                    )
                  ],
                ),
        ],
      ),
    );
  }

  Widget commentUI(String cmnt_name, String cmnt_image, String cmnt, var id, var time) {
    return GestureDetector(
      onTap: ()async{
        if(id != _userid){
          friendProfile fp = new friendProfile(id, cmnt_name, cmnt_image);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>friendprofile(data: fp)));
        }
        else if(id == _userid){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>profile()));
        }

      },
      child: Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(left: 10.0),
              ),
              new Container(
                width: 40,
                height: 40,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage('$cmnt_image'),
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
                      '$cmnt',
                      maxLines: 2,
                      style: new TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 15.0,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(bottom: 3.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(
                          '$cmnt_name',
                          style: new TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: new Text('$time',
                              style: new TextStyle(
                                color: Colors.white,
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
//end