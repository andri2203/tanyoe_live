import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:lets_live/model/ChannelModel.dart';
import 'package:lets_live/model/UserModel.dart';
import 'package:lets_live/widget/chatRoom.dart';

const APP_ID = 'd551104ea755456ea3e7e02d6c05a392';

class Audience extends StatefulWidget {
  final ChannelModel channel;
  final UserModel userModel;
  const Audience({Key key, this.channel, this.userModel}) : super(key: key);

  @override
  _AudienceState createState() => _AudienceState();
}

class _AudienceState extends State<Audience> {
  List<UserModel> _audience = new List<UserModel>();
  UserModel get user => widget.userModel;
  ChannelModel get channel => widget.channel;

  Firestore firestore = Firestore.instance;

  bool isLoading = false;
  bool showComment = true;

  FloatingActionButton button = FloatingActionButton(
    backgroundColor: Colors.amber,
    child: Icon(
      Icons.favorite,
      size: 30,
    ),
    onPressed: () {},
  );

  @override
  void dispose() {
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
      AgoraRtcEngine.create(APP_ID);
      AgoraRtcEngine.enableVideo();
      AgoraRtcEngine.setEnableSpeakerphone(true);
      _addAgoraEventHandlers();
      AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
      AgoraRtcEngine.setClientRole(ClientRole.Audience);
      AgoraRtcEngine.enableWebSdkInteroperability(true);
      AgoraRtcEngine.setParameters(
          '{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
    } catch (e) {
      print("==================================================");
      print('Init: $e');
      print("==================================================");
    }
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        // _infoStrings.add(info);
        print(info);
      });
    };

    AgoraRtcEngine.onRemoteAudioStats = (remote) {
      print("==================================================");
      print(remote.audioLossRate);
      print("==================================================");
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        // _infoStrings.add(info);
        print(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        // _infoStrings.add('onLeaveChannel');
        // _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        print(info);
        print(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        print(info);
        print(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        print(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (string, i, j) {
      print("===================ChannelSuccess=================");
      print(string);
      print('$i');
      print('$j');
      print("==================================================");
    };
  }

  Future<bool> _backButtonHandler() {
    return showDialog(
          context: context,
          builder: (context) => !isLoading
              ? AlertDialog(
                  title: Text('Apakah Anda Yakin?'),
                  content: Text('Ingin menutup siaran ini?'),
                  actions: <Widget>[
                    RaisedButton(
                      color: Colors.red,
                      child: Text('Tidak'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    RaisedButton(
                      color: Colors.green,
                      child: Text('Ya'),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        AgoraRtcEngine.leaveChannel();
                        AgoraRtcEngine.destroy();
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text("Menghapus data siaran langsung"),
                  content: Center(child: CircularProgressIndicator()),
                ),
        ) ??
        false;
  }

  _videoView() {
    try {
      final view = AgoraRtcEngine.createNativeView((viewId) {
        AgoraRtcEngine.joinChannel(null, channel.channelID, null, user.userID);
        AgoraRtcEngine.setupRemoteVideo(
            viewId, VideoRenderMode.Fit, channel.uID);
      });
      return view;
    } catch (e) {
      print('Video: $e');
    }
  }

  Widget _videoContainer(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          _videoView(),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              child: Row(children: <Widget>[
                FlutterLogo(colors: Colors.amber, size: 20),
                SizedBox(width: 5),
                Text(
                  channel.channel,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber),
                )
              ]),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.black),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "${_audience.length}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              left: 10,
              bottom: 10,
              child: showComment
                  ? ChatRoom(user: user, channel: channel)
                  : Container()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return WillPopScope(
      onWillPop: _backButtonHandler,
      child: Scaffold(
        body: _videoContainer(context),
        floatingActionButton: button,
      ),
    );
  }
}
