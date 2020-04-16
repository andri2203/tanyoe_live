import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_live/model/UserModel.dart';
import 'package:lets_live/pages/Profil.dart';

class DrawerWidget extends StatefulWidget {
  final UserModel user;
  const DrawerWidget({Key key, this.user}) : super(key: key);
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  UserModel user = new UserModel();

  @override
  void initState() {
    super.initState();
    currentUser();
  }

  Future currentUser() async {
    setState(() {
      user = widget.user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber,
            ),
            currentAccountPicture: user.foto == '' || user.foto == null
                ? CircleAvatar()
                : CircleAvatar(
                    backgroundImage: NetworkImage(
                      user.foto,
                    ),
                  ),
            accountName: Text(user.nama),
            accountEmail: Text(user.email),
            otherAccountsPictures: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    user.getUser().then((_user) {
                      setState(() {
                        user = _user;
                      });
                    });
                  }),
            ],
          ),
          ListTile(
            title: Text("Profil"),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Profil(
                  user: user,
                ),
              ));
            },
          ),
          ListTile(
            title: Text("Keluar"),
            trailing: Icon(Icons.exit_to_app),
            onTap: () {
              auth.signOut().whenComplete(
                  () => Navigator.of(context).pushReplacementNamed('/'));
            },
          ),
        ],
      ),
    );
  }
}
