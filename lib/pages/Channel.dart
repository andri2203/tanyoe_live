import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_live/model/ChannelModel.dart';
import 'package:lets_live/model/UserModel.dart';
import 'package:lets_live/pages/Host.dart';

class Channel extends StatefulWidget {
  @override
  _ChannelState createState() => _ChannelState();
}

class _ChannelState extends State<Channel> {
  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var channelName = TextEditingController();
  final Firestore firestore = Firestore.instance;
  int channelInt = Random.secure().nextInt(99999);
  DateTime time = DateTime.now();
  String channelID;
  bool isLoading = false;
  File _image;

  @override
  void initState() {
    setState(() {
      channelID = 'CH-' + channelInt.toString() + '-${time.year}';
    });
    super.initState();
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    Image images = Image.file(image);

    Uint8List imageByte = image.readAsBytesSync();
    print("${imageByte.length}");

    images.image
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener(
      (info, _) {
        int width = info.image.width;
        int height = info.image.height;

        if (width >= height) {
          setState(() {
            _image = image;
          });
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.red,
            content: Text(
                "Gambar yang anda pilih adalah gambar Potrait. Mohon Pilih Gambar Landscape"),
          ));
        }
      },
    ));
  }

  Future<String> saveImage() async {
    if (_image != null) {
      StorageReference storage =
          FirebaseStorage.instance.ref().child('channel/$channelID.jpg');
      StorageUploadTask upload = storage.putFile(_image);

      String uriNetwork = await (await upload.onComplete).ref.getDownloadURL();
      return uriNetwork;
    } else {
      return null;
    }
  }

  Future<void> createChannel() async {
    UserModel user = await UserModel().getUser();
    CollectionReference ref = firestore.collection('channel');
    try {
      if (formKey.currentState.validate()) {
        setState(() {
          isLoading = true;
        });

        String imageUri = await saveImage();

        Map<String, dynamic> data = {
          'channelID': channelID,
          'uID': user.userID,
          'channel': channelName.text,
          'create_at': time.millisecondsSinceEpoch,
          'is_active': true,
          'image': imageUri,
        };

        await ref.document(channelID).setData(data).catchError((error) {
          print("Error: $error");
        }).whenComplete(() {
          setState(() {
            channelName.text = '';
            isLoading = false;
          });
          Navigator.pop(context);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Host(
              channel: ChannelModel.createChannel(data),
              userModel: user,
            ),
          ));
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.red,
        content: Text(e.message),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(backgroundColor: Colors.amber, title: Text("Set Channel")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: Icon(Icons.add_circle_outline, size: 35),
        onPressed: createChannel,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: !isLoading
            ? GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  children: <Widget>[
                    Text("*Silahkan Setting Channel Anda."),
                    SizedBox(height: 10),
                    GestureDetector(
                      child: _image == null
                          ? Image.asset(
                              'assets/no-image.png',
                              fit: BoxFit.fitWidth,
                            )
                          : Image.file(_image),
                      onTap: getImage,
                    ),
                    SizedBox(height: 10),
                    Form(
                      key: formKey,
                      child: TextFormField(
                        controller: channelName,
                        validator: (value) => value.isEmpty
                            ? 'Channel Tidak Boleh Kosong'
                            : value.length < 5
                                ? 'Channel minimal 5 karakter'
                                : null,
                        decoration: InputDecoration(
                          hintText: 'Channel',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
