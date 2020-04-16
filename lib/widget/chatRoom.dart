import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_live/model/ChannelModel.dart';
import 'package:lets_live/model/UserModel.dart';

class ChatRoom extends StatefulWidget {
  final UserModel user;
  final ChannelModel channel;

  ChatRoom({
    Key key,
    @required this.user,
    @required this.channel,
  }) : super(key: key);
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  CollectionReference ref = Firestore.instance.collection('chat-room');

  UserModel get user => widget.user;
  ChannelModel get channel => widget.channel;

  var chatController = new TextEditingController();
  int id = Random().nextInt(9999);
  DateTime now = DateTime.now();

  Future<void> setChat() async {
    if (chatController.text.isNotEmpty || chatController.text != ' ') {
      Map<String, dynamic> data = {
        'chatID': "ct-" + id.toString(),
        'channelID': channel.channelID,
        'user': user.nama,
        'chat': chatController.text,
        'time': now.millisecondsSinceEpoch,
      };
      await Firestore.instance
          .collection('chat-room')
          .document()
          .setData(data)
          .whenComplete(() {
        setState(() {
          chatController.text = '';
        });
        FocusScope.of(context).unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(child: listChat(context: context)),
          SizedBox(height: 10),
          formChat(context: context),
        ],
      ),
    );
  }

  Widget listChat({BuildContext context}) {
    return StreamBuilder<QuerySnapshot>(
      stream: ref
          .where('channelID', isEqualTo: channel.channelID)
          .orderBy('time', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text('');
        return Container(
          width: 200,
          child: ListView(
            dragStartBehavior: DragStartBehavior.start,
            shrinkWrap: true,
            children: snapshot.data.documents.map((item) {
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: ListTile(
                  title: Text(item.data['user']),
                  subtitle: Text(item.data['chat']),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget formChat({BuildContext context}) {
    return Container(
      padding: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            bottom: BorderSide(color: Colors.amber),
            left: BorderSide(color: Colors.amber),
            right: BorderSide(color: Colors.amber),
            top: BorderSide(color: Colors.amber),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 200,
            child: TextField(
              controller: chatController,
              decoration: InputDecoration(
                hintText: "Komentar",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Colors.amber,
            onPressed: setChat,
          ),
        ],
      ),
    );
  }
}
