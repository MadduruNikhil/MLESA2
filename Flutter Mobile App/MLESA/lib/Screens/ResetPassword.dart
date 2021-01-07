import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import './AuthScreen.dart';

class ResetPassword extends StatefulWidget {
  static const routename = './resetPassword';
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final resetpasswordglobalKey = GlobalKey<ScaffoldState>();
  final resetemailcontroller = TextEditingController();

  @override
  void dispose() {
    resetemailcontroller.dispose();
    super.dispose();
  }

  Future<void> submitemailtoreset(String emailAddress) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.sendPasswordResetEmail(email: emailAddress);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          child: Card(
            child: Center(
              child: Column(
                children: [
                  Text(
                      'Reset Passwrod Link has been sent to the given Email Credential!'),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context)
                          .popAndPushNamed(AuthScreen.routename);
                    },
                    child: Text('Back!'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicesize = MediaQuery.of(context).size;
    return Scaffold(
      key: resetpasswordglobalKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        height: devicesize.height,
        width: devicesize.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('./assets/images/Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            margin: EdgeInsets.all(20),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: resetemailcontroller,
                    decoration: InputDecoration(labelText: 'Email Address'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    color: Colors.amber,
                    child: Text('Reset'),
                    onPressed: () async {
                      if (resetemailcontroller.value.text.isNotEmpty) {
                        await submitemailtoreset(
                            resetemailcontroller.value.text);
                      } else {
                        resetpasswordglobalKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text('Please Enter a Valid Email'),
                            backgroundColor: Theme.of(context).errorColor,
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
