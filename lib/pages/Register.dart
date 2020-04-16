import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:lets_live/model/UserModel.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var namaField = TextEditingController();
  var emailField = TextEditingController();
  var passwordField = TextEditingController();
  var passwordKonfField = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool onLoading = false;
  int userID = Random.secure().nextInt(99999);

  @override
  void initState() {
    super.initState();
  }

  void _clearForm() {
    setState(() {
      namaField.text = '';
      emailField.text = '';
      passwordField.text = '';
      passwordKonfField.text = '';
      onLoading = false;
    });
  }

  Future<void> _userRegistrasi() async {
    setState(() {
      onLoading = true;
    });
    try {
      if (formKey.currentState.validate()) {
        try {
          await auth
              .createUserWithEmailAndPassword(
            email: emailField.text.trim(),
            password: passwordField.text,
          )
              .then((value) {
            final FirebaseUser user = value.user;

            UserModel().createUser({
              'userID': userID,
              'nama': namaField.text,
              'email': emailField.text.trim(),
              'image': null,
            }, user.uid);
          }).whenComplete(() {
            _clearForm();

            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Akun berhasil di buat"),
            ));
          });
        } on AuthException catch (e) {
          _clearForm();
          _handleError(e.message);
        }
      }
    } on PlatformException catch (e) {
      _clearForm();
      _handleError(e.message);
    }
  }

  void _handleError(String message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 10),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.red,
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: GestureDetector(
            child: ListView(
              children: <Widget>[
                FlutterLogo(
                  colors: Colors.amber,
                  size: 120,
                ),
                SizedBox(height: 10),
                !onLoading
                    ? Container(
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              TextFormField(
                                controller: namaField,
                                validator: (value) => value.isEmpty
                                    ? 'Nama Tidak Boleh Kosong'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Nama',
                                  icon: Icon(Icons.person),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: emailField,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value.isEmpty
                                    ? 'Email Tidak Boleh Kosong'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  icon: Icon(Icons.email),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: passwordField,
                                validator: (value) => value.isEmpty
                                    ? 'Password Tidak Boleh Kosong'
                                    : value.length < 6
                                        ? 'Password Minimal 6 Karakter'
                                        : null,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  icon: Icon(Icons.vpn_key),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: passwordKonfField,
                                validator: (value) => value.isEmpty
                                    ? 'Password Tidak Boleh Kosong'
                                    : value.length < 6
                                        ? 'Password Minimal 6 Karakter'
                                        : value != passwordField.text
                                            ? 'Password Konfirmasi tidak sesuai.'
                                            : null,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Konfirmasi Password',
                                  icon: Icon(Icons.vpn_key),
                                ),
                              ),
                              SizedBox(height: 20),
                              RaisedButton(
                                color: Colors.amber,
                                child: Text('Register',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: _userRegistrasi,
                              ),
                              SizedBox(height: 10),
                              Text('ATAU', textAlign: TextAlign.center),
                              SizedBox(height: 10),
                              RaisedButton(
                                color: Colors.deepOrange,
                                child: Text('Login',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            ),
            onTap: () => FocusScope.of(context).unfocus(),
          ),
        ),
      ),
    );
  }
}
