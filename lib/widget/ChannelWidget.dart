import 'package:flutter/material.dart';
import 'package:lets_live/model/ChannelModel.dart';
import 'package:lets_live/model/UserModel.dart';
import 'package:intl/intl.dart';
import 'package:lets_live/pages/Audience.dart';

class ChannelWidget extends StatefulWidget {
  final ChannelModel channel;
  final UserModel user;

  const ChannelWidget({Key key, @required this.channel, @required this.user})
      : super(key: key);

  @override
  _ChannelWidgetState createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {
  UserModel me;
  UserModel get user => widget.user;
  ChannelModel get channel => widget.channel;

  @override
  void initState() {
    super.initState();
  }

  // Future getUser() async {
  //   var userModel = await UserModel().getUserByID(channel.uID);
  //   setState(() {
  //     me = userModel;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // getUser();
    var tanggal = new DateFormat('EEE, dd MMM yyyy hh:mm').format(
      DateTime.fromMillisecondsSinceEpoch(widget.channel.createAt),
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Audience(
          channel: channel,
          userModel: widget.user,
        ),
      )),
      child: Container(
        width: double.infinity,
        height: 200,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            channel.foto == null
                ? Image.asset(
                    'assets/no-image.png',
                    fit: BoxFit.fill,
                  )
                : Image.network(
                    channel.foto,
                    fit: BoxFit.fill,
                  ),
            // Logo
            Positioned(
              top: 10,
              left: 10,
              height: 25,
              width: 25,
              child: FlutterLogo(size: 10, colors: Colors.amber),
            ),
            // Nama Channel
            Positioned(
              child: Container(
                width: 120,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  shape: BoxShape.rectangle,
                  color: Colors.amber,
                ),
                child: Text(
                  widget.channel.channel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              top: 10,
              right: 10,
            ),
            // User
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    user.foto == '' || user.foto == null
                        ? CircleAvatar()
                        : CircleAvatar(
                            backgroundImage: NetworkImage(
                              user.foto,
                            ),
                          ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            shape: BoxShape.rectangle,
                            color: Colors.amber,
                          ),
                          child: Text(
                            me != null ? me.nama : 'Anonymous',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            shape: BoxShape.rectangle,
                            color: Colors.amber,
                          ),
                          child: Text(tanggal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
