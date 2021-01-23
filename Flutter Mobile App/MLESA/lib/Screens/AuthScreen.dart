import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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
        const url =
            'https://westus.api.cognitive.microsoft.com/speaker/verification/v2.0/text-independent/profiles';
        final response = await http.post(
          url,
          headers: {
            "Ocp-Apim-Subscription-Key": "6c66a2e5fe1c4a68a401fa1967012192",
            "Content-Type": "application/json"
          },
          body: json.encode(
            {
              "locale": "en-us",
            },
          ),
        );
        print(response.body);
        Map<String, dynamic> data = json.decode(response.body);
        await Firestore.instance
            .collection('Users/${authResult.user.uid}/VoiceMapping')
            .document(authResult.user.uid)
            .setData(
          {
            'VoiceProfileID': data['profileId'],
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

      // ignore: deprecated_member_use
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
          image: DecorationImage(
            image: AssetImage('./assets/images/Background.png'),
            fit: BoxFit.cover,
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
