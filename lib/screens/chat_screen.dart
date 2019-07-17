import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/services.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').getDocuments();
  //   for (var msg in messages.documents) {
  //     print(msg.data);
  //   }
  // }

  // void messagesStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var msg in snapshot.documents) {
  //       print(msg.data);
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop'),
          icon: Icon(Icons.arrow_back),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      msgTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var msg in messages) {
          final msgText = msg.data['text'];
          final msgSender = msg.data['sender'];
          final currentUser = loggedInUser.email;
          final msgBubble = MessageBubble(
            sender: msgSender,
            text: msgText,
            isMe: currentUser == msgSender,
          );
          messageBubbles.add(msgBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
            children: messageBubbles,
          ),
        );
      },
      stream: _firestore.collection('messages').snapshots(),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageBubble({this.sender, this.text, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(fontSize: 12.0, color: Colors.black45),
          ),
          SizedBox(
            height: 2.0,
          ),
          Material(
            elevation: 4.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    bottomLeft: Radius.circular(24.0),
                    bottomRight: Radius.circular(24.0))
                : BorderRadius.only(
                    topRight: Radius.circular(24.0),
                    bottomLeft: Radius.circular(24.0),
                    bottomRight: Radius.circular(24.0)),
            color: isMe ? Colors.orangeAccent : Colors.grey[100],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '$text',
                style: TextStyle(
                    color: isMe ? Colors.grey[100] : Colors.black54,
                    fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
