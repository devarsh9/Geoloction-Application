import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/const.dart';
import 'package:intl/intl.dart';

int index;

class Chat extends StatelessWidget {
  final String peerId;
  final String name;
  final String uid;
  Chat(
      {Key key, @required this.peerId, @required this.name, @required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blue[600],
        title: new Text(
          name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new ChatScreen(
        uid: uid,
        peerId: peerId,
        name: name,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String name;
  final String uid;

  ChatScreen(
      {Key key, @required this.peerId, @required this.name, @required this.uid})
      : super(key: key);

  @override
  State createState() =>
      new ChatScreenState(peerId: peerId, name: name, uid: uid);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState(
      {Key key,
        @required this.peerId,
        @required this.name,
        @required this.uid});
  String peerId;
  String name;
  String uid;
  var listMessage;
  String groupChatId;

  bool isLoading;

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    groupChatId = '';
    readLocal();
  }

  readLocal() async {
    //prefs = await SharedPreferences.getInstance();
    // print(prefs);
    print(uid);
    print(uid.hashCode);
    print(peerId.hashCode);
    print('$uid-$peerId');
    //id = prefs.getString('id') ?? '';
    if (uid.hashCode <= peerId.hashCode) {
      groupChatId = '$uid-$peerId';
    } else {
      groupChatId = '$peerId-$uid';
    }

    Firestore.instance
        .collection('Users')
        .document(uid)
        .updateData({'chattingWith': peerId});

    setState(() {});
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': uid,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Text('Nothing to send');
    }
  }

  Future<bool> onBackPress() {
    Firestore.instance
        .collection('Users')
        .document(uid)
        .updateData({'chattingWith': null});
    Navigator.pop(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Sticker
              (Container()),

              // Input content
              buildInput(),
            ],
          ),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildInput() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 6.0),
      child: Row(
        children: <Widget>[
          // Button send image
          // Edit text
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 6.0),
              child: TextField(

                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                // focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send,color: Colors.green[900],),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.grey[300],
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
          new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            List<DocumentSnapshot> docs = snapshot.data.documents;
            List<Widget> messages = docs
                .map((doc) => Message(
              from: doc.data['idFrom'],
              text: doc.data['content'],
              me: uid == doc.data['idFrom'],
              time:doc.data['timestamp'],
            ))
                .toList();
            return ListView(
              reverse: true,
              controller: listScrollController,
              children: <Widget>[
                ...messages,
              ],
            );
          }
        },
      ),
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;
  final bool me;
  final String time;

  const Message({Key key, this.from, this.text, this.me, this.time}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if(text.isNotEmpty) {
      print(me);
      print(text);
      print(from);
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0,horizontal: 6.0),
        padding: EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
        child: Column(
          crossAxisAlignment:
          me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              DateFormat('dd MMM kk:mm')
                  .format(DateTime.fromMillisecondsSinceEpoch(int.parse(time))),style: TextStyle(fontSize: 10.0),
            ),
            Material(

              color: me ? Colors.greenAccent : Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
              elevation: 6.0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,style: TextStyle(fontSize: 16.0),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
