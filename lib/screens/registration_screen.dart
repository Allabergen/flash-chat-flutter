import 'package:flash_chat/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';

import '../constants.dart';
import 'chat_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final txtTextController = TextEditingController();
  final psdTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool isLoading = false;

  void register(BuildContext context) async {
    setState(() => isLoading = true);

    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (newUser != null) {
        Navigator.pushNamed(context, ChatScreen.id);
      }

      setState(() {
        isLoading = false;
        email = '';
        password = '';
      });
    } catch (e) {
      Toast.show('Please enter correct data.', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print(e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ModalProgressHUD(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  child: Container(
                    height: 150.0,
                    child: Image.asset('images/logo.png'),
                  ),
                  tag: 'logo',
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                controller: txtTextController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: psdTextController,
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: Colors.deepOrangeAccent,
                title: 'Register',
                onPressed: () {
                  txtTextController.clear();
                  psdTextController.clear();
                  register(context);
                },
              ),
            ],
          ),
        ),
        inAsyncCall: isLoading,
      ),
    );
  }
}
