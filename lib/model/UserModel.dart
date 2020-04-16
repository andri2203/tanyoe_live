import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uID;
  final int userID;
  final String nama;
  final String email;
  final String foto;
  final Firestore firestore = Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  UserModel(
      {this.uID = '', this.userID, this.nama = '', this.email = '', this.foto});

  factory UserModel.createUser(DocumentSnapshot snap) {
    return UserModel(
      uID: snap.documentID,
      userID: snap.data['userID'],
      nama: snap.data['nama'],
      email: snap.data['email'],
      foto: snap.data['image'],
    );
  }

  factory UserModel.createUserMap(Map<String, dynamic> data) {
    return UserModel(
      userID: data['userID'],
      nama: data['nama'],
      email: data['email'],
      foto: data['image'],
    );
  }

  Future createUser(Map<String, dynamic> map, String uID) async {
    try {
      await firestore.collection('user').document(uID).setData(map);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<UserModel> getUser() async {
    FirebaseUser user = await auth.currentUser();
    var result = await firestore
        .collection('user')
        .document(user.uid)
        .get(source: Source.server);

    return UserModel.createUser(result);
  }

  Future<UserModel> getUserByID(int uid) async {
    var result = await firestore
        .collection('user')
        .where('userID', isEqualTo: uid)
        .getDocuments();

    return UserModel.createUserMap(result.documents[0].data);
  }
}
