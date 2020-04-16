import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelModel {
  final String channelID;
  final int uID;
  final String channel;
  final int createAt;
  final bool isActive;
  final dynamic foto;

  ChannelModel({
    this.channelID,
    this.uID,
    this.channel,
    this.createAt,
    this.isActive,
    this.foto,
  });

  factory ChannelModel.createChannel(Map<String, dynamic> doc) {
    return ChannelModel(
      channelID: doc['channelID'],
      channel: doc['channel'],
      createAt: doc['create_at'],
      isActive: doc['is_active'],
      uID: doc['uID'],
      foto: doc['image'],
    );
  }

  factory ChannelModel.createChannelFromDocument(DocumentSnapshot doc) {
    return ChannelModel(
      channelID: doc['channelID'],
      channel: doc['channel'],
      createAt: doc['create_at'],
      isActive: doc['is_active'],
      uID: doc['uID'],
      foto: doc['image'],
    );
  }
}
