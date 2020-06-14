const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.postNotification = functions.database.ref('node-name/{timestamp}').onWrite(evt => {
    var send = false;
    var newdata = evt.after._data;
    if(newdata.userid!=null && newdata.name != null && newdata.msgtime!=null && 
        newdata.message!=null && newdata.image!=null && newdata.comments !=null && newdata.likes != null){
        send = true;
    }

    const payload = {
        notification:{
            title : evt._data.name,
            body : evt._data.message,
            badge : '1',
            sound : 'default'
        }
    };

    if(send){
        return admin.database().ref('fcm-token').once('value').then(allToken => {
            if(allToken.val()){
                const token = Object.keys(allToken.val());
                return admin.messaging().sendToDevice(token,payload);
            }
        });
    }
});

exports.message = functions.database.ref('user/{user-id}/message/{friend-id}/{timestamp}').onWrite(evt => {
    var FriendId = 404;
    if(evt.after._data.name != null && evt.after._data.message != null && evt.after._data.id != null && evt.after._data.friendid != null && evt.after._data.time !=null && evt.after._data.image != null){
        FriendId = evt.after._data.friendid;
        console.log("lol :", FriendId);
    }
    const payload = {
        notification:{
            title : evt.after._data['name'],
            body : evt.after._data.message,
            badge : '1',
            sound : 'default'
        }
    };

    if(FriendId != 404 && FriendId != "Dummy data"){
        return admin.database().ref('user/'+FriendId+'/fcm-token').on('value', (token)=>{
            console.log("code token :", token.val());
            return admin.messaging().sendToDevice(token.val(), payload);
        });
    }
});

exports.comment = functions.database.ref('node-name/{timestamp}/comments/{msgtimestamp}').onWrite(evt =>{

    var userid = 404;
    if(evt.after._data.comment != null && evt.after._data.id != null != null && evt.after._data.name != null && evt.after._data.postid != null){
        userid = evt.after._data.postid;
        console.log("Comment msg :", userid, evt.after._data);
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


exports.newuser = functions.database.ref('newuser').onWrite(evt => {
    var send = false;
    console.log("Data :",evt.after._data);

    if(evt.after._data != null){
        send = true;
    }

    const payload = {
        notification:{
            title : "New user joined Post-it",
            body : "Say hi to "+evt.after._data,
            badge : '1',
            sound : 'default'
        }
    };

    if(send){
        return admin.database().ref('fcm-token').once('value').then(allToken => {
            if(allToken.val()){
                const token = Object.keys(allToken.val());
                return admin.messaging().sendToDevice(token,payload);
            }
        });
    }
});