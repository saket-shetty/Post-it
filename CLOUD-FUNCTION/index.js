const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.helloWorld = functions.database.ref('notification').onWrite(evt => {
    console.log("data :", evt.after._data.data);
    const payload = {
        notification:{
            title : evt.after._data.name,
            body : evt.after._data.message,
            badge : '1',
            sound : 'default'
        }
    };

    return admin.database().ref('fcm-token').once('value').then(allToken => {
        if(allToken.val()){
            console.log('token available');
            const token = Object.keys(allToken.val());
            return admin.messaging().sendToDevice(token,payload);
        }else{
            console.log('No token available');
        }
    });
});


exports.message = functions.database.ref('user/{user-id}/message/{friend-id}/{timestamp}').onWrite(evt => {
    var FriendId = 404;

    if(evt.after._data.name != null && evt.after._data.message != null && evt.after._data.id != null && evt.after._data.friendid != null && evt.after._data.time !=null && evt.after._data.image != null){
        console.log("12345656 :", evt.after._data['friend-name']);
        FriendId = evt.after._data.friendid
    }

    const payload = {
        notification:{
            title : evt.after._data['friend-name'],
            body : evt.after._data.message,
            badge : '1',
            sound : 'default'
        }
    };

    if(FriendId != 404){
        console.log("FriendID : ", FriendId);
        return admin.database().ref('user/'+FriendId+'/fcm-token').on('value', (token)=>{
            console.log("code here");
            console.log(token.val());
            return admin.messaging().sendToDevice(token.val(), payload);
        });
    }
});

exports.comment = functions.database.ref('node-name/{timestamp}/comments/{msgtimestamp}').onWrite(evt =>{
    console.log(evt);

    var userid = 404;

    if(evt.after._data.comment != null && evt.after._data.id != null != null && evt.after._data.name != null && evt.after._data.postid != null){
        userid = evt.after._data.postid;
    }

    const payload = {
        notification:{
            head: "Comment",
            title : evt.after._data.comment,
            body : evt.after._data.name,
            badge : '1',
            sound : 'default'
        }
    }

    if(userid != 404){
        return admin.database().ref('user/'+userid+'/fcm-token').on('value', (token)=>{
            return admin.messaging().sendToDevice(token.val(), payload);
        });
    }
});