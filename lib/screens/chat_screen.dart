import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id='chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore=Firestore.instance;
  final _auth=FirebaseAuth.instance;
   var  loggedInUser;

  String messageText;




  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  //check user is already sign
  void getCurrentUser() async {
    try {
      final  user = await _auth.currentUser;
       // if (user != null)
          loggedInUser = user;
       {
        print(loggedInUser.email);
       }
    }
    catch(e)
    {
      print(e);
    }
  }
// void getMessages() async {
//    final messages= await _firestore.collection('messages').get();
//    for(var message in messages.docs){
//      print(message.data());
//
//    }
// }
  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                messagesStream();
                // _auth.signOut();
                // Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              //when new data comes it automatically provided
              stream: _firestore.collection('messages').snapshots(),
              builder: (context,snapshot){
                if(!snapshot.hasData){
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.lightGreenAccent,
                        ),
                      );
                }
                  // ignore: missing_return
                  final messages =snapshot.data.docs;
                  List<Text> messageWidgets=[];
                  for(var message in messages){
                    final messageText=message.data()['text'];
                    final mesageSender=message.data()['sender'];

                    final messageWidget=
                    Text('$messageText from $mesageSender');
                    messageWidgets.add(messageWidget);
                  }
                  return Column(
                    children: messageWidgets,
                  );


              },



            ),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      _firestore.collection('messages').add({
                        'text':messageText,
                        'sender':loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
