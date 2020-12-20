import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../widgets/AuthForm.dart';

import './ResetPassword.dart';

class AuthScreen extends StatefulWidget {
  static const routename = './AuthScreen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isloading = false;

  void _submitAuthForm(
    String email,
    String userName,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) async {
    AuthResult authResult;
    try {
      setState(() {
        _isloading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await Firestore.instance
            .collection('Users')
            .document(authResult.user.uid)
            .setData(
          {
            'UserName': userName,
            'Email': email,
          },
        );

        await Firestore.instance
            .collection('Users/${authResult.user.uid}/FaceMapping')
            .document(authResult.user.uid)
            .setData(
          {
            'UploadedImage': false,
            'VerifyImageData': '',
            'LeftImageData': '',
            'RightImageData': '',
            'FrontImageData': '',
          },
        );
        await Firestore.instance
            .collection('Users/${authResult.user.uid}/VoiceMapping')
            .document(authResult.user.uid)
            .setData(
          {
            'UploadedVoice': false,
            'VoiceData': '',
            'UploadedVoiceData': '',
          },
        );
      }
    } on PlatformException catch (err) {
      var message = 'An Error occured , Please Check Again!';
      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isloading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        alignment: Alignment.center,
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple,
              Colors.pink,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.amber,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'MLESA',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              AuthForm(
                _submitAuthForm,
                _isloading,
              ),
              RaisedButton(
                color: Colors.amber,
                onPressed: () {
                  Navigator.of(context).pushNamed(ResetPassword.routename);
                },
                child: Text('Forgot Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
