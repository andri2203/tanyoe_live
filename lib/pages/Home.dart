import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_live/model/ChannelModel.dart';
import 'package:lets_live/model/UserModel.dart';
import 'package:lets_live/widget/ChannelWidget.dart';
import 'package:lets_live/widget/Drawer.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserModel user;
  Firestore firestore = Firestore.instance;

  @override
  void initState() {
    currentUser();
    super.initState();
  }

  Future currentUser() async {
    UserModel _user = await UserModel().getUser();
    setState(() {
      user = _user;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return Scaffold(
      appBar: AppBar(
        title: Text("Tanyoe Live"),
        backgroundColor: Colors.amber,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: DrawerWidget(
        user: user,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: Icon(Icons.play_circle_outline, size: 35),
        onPressed: () => Navigator.of(context).pushNamed('/channel'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('channel')
              .where('is_active', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                return new ListView(
                  children: snapshot.data.documents.map((DocumentSnapshot doc) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: ChannelWidget(
                        channel: ChannelModel.createChannelFromDocument(doc),
                        user: user,
                      ),
                    );
                  }).toList(),
                );
            }
          },
        ),
      ),
    );
  }
}
