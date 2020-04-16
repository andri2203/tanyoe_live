import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var emailField = TextEditingController();
  var passwordField = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool onLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void clearForm() {
    setState(() {
      emailField.text = '';
      passwordField.text = '';
      onLoading = false;
    });
  }

  Future<void> _loginHandler() async {
    setState(() {
      onLoading = true;
    });
    try {
      if (formKey.currentState.validate()) {
        try {
          await auth.signInWithEmailAndPassword(
            email: emailField.text.trim(),
            password: passwordField.text,
          );

          clearForm();

          Navigator.of(context).pushReplacementNamed('/home');
        } on AuthException catch (e) {
          clearForm();
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
    } on PlatformException catch (e) {
      clearForm();
      return scaffoldKey.currentState.showSnackBar(SnackBar(
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          child: GestureDetector(
            child: ListView(
              children: <Widget>[
                FlutterLogo(
                  colors: Colors.amber,
                  size: 180,
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
                              SizedBox(height: 20),
                              RaisedButton(
                                color: Colors.amber,
                                child: Text('Login',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: _loginHandler,
                              ),
                              SizedBox(height: 10),
                              Text('ATAU', textAlign: TextAlign.center),
                              SizedBox(height: 10),
                              RaisedButton(
                                color: Colors.deepOrange,
                                child: Text('Register',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/register'),
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
