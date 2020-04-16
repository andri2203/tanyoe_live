import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_live/model/ChannelModel.dart';
import 'package:lets_live/model/UserModel.dart';
import 'package:intl/intl.dart';

class Profil extends StatefulWidget {
  final UserModel user;

  const Profil({Key key, this.user}) : super(key: key);
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  UserModel user;
  Firestore firestore = Firestore.instance;
  DateTime now = DateTime.now();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;
  DateFormat format = DateFormat('EE, dd MMM y HH:mm:ss');
  var namaUpControl = new TextEditingController();

  @override
  void initState() {
    setState(() {
      user = widget.user;
    });
    super.initState();
  }

  getUserImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        isLoading = true;
      });
      StorageReference ref = FirebaseStorage.instance.ref().child(
          'User/user_img_${user.userID}_${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}.jpg');
      StorageUploadTask upload = ref.putFile(image);
      CollectionReference collection = firestore.collection('user');
      String imageUrl = await (await upload.onComplete).ref.getDownloadURL();

      await collection
          .document(user.uID)
          .updateData({
            'image': imageUrl,
          })
          .catchError(
            (error) => print('Error: $error'),
          )
          .whenComplete(
            () {
              print("Foto Profil Berhasil di ganti");
              UserModel().getUser().then((UserModel value) {
                setState(() {
                  user = value;
                  isLoading = false;
                });
              });
            },
          );
    }
  }

  updateNama(BuildContext context) {
    setState(() {
      namaUpControl.text = '';
    });
    showDialog(
      context: context,
      child: AlertDialog(
        content: Form(
          key: formKey,
          child: TextFormField(
              controller: namaUpControl,
              validator: (value) => value == ''
                  ? 'Nama Tidak Boleh Kosong'
                  : value.length < 8 ? 'Nama harus 8 karakter' : null,
              decoration: InputDecoration(hintText: 'Update Nama Anda')),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text(
              'Update',
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () {
              if (formKey.currentState.validate()) {
                firestore.collection('user').document(user.uID).updateData({
                  'nama': namaUpControl.text,
                }).whenComplete(() {
                  UserModel().getUser().then((UserModel value) {
                    setState(() {
                      user = value;
                    });
                  });
                  Navigator.pop(context);
                });
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.nama),
        backgroundColor: Colors.amber,
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: ListView(
          children: <Widget>[
            userCard(context),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Riwayat Live",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            liveHistory(context),
          ],
        ),
      ),
    );
  }

  Widget liveHistory(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('channel')
            .where('uID', isEqualTo: user.userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              return new Column(
                children: snapshot.data.documents.map((DocumentSnapshot doc) {
                  ChannelModel channel =
                      ChannelModel.createChannelFromDocument(doc);
                  DateTime waktu =
                      DateTime.fromMillisecondsSinceEpoch(channel.createAt);
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(channel.channelID),
                      subtitle: Text('${format.format(waktu)}'),
                      trailing: Icon(
                        Icons.remove_red_eye,
                      ),
                    ),
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }

  Widget userCard(BuildContext context) {
    return Card(
      child: Container(
        margin: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            !isLoading
                ? GestureDetector(
                    child: user.foto == '' || user.foto == null
                        ? CircleAvatar()
                        : CircleAvatar(
                            backgroundImage: NetworkImage(
                              user.foto,
                            ),
                          ),
                    onTap: getUserImage,
                  )
                : CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Nama : ' + user.nama),
                  Text('Email : ' + user.email),
                  Text('UserID : ' + user.userID.toString()),
                ],
              ),
            ),
            SizedBox(width: 10),
            IconButton(
                icon: Icon(Icons.edit), onPressed: () => updateNama(context))
          ],
        ),
      ),
    );
  }
}
