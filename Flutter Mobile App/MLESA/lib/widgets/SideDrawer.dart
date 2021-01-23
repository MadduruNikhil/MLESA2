import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../Screens/HomeScreen.dart';
import '../Screens/FaceRecognitionScreen.dart';
import '../Screens/UpdateScreen.dart';
import '../Screens/UpdateVoiceScreen.dart';
import '../Screens/VoiceVerification.dart';
import '../Screens/UserDetails.dart';
import '../Screens/SignatureScreen.dart';
import '../Screens/AuthScreen.dart';

class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple,
              Colors.pink,
            ],
          ),
        ),
        child: ListView(
          children: [
            
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    width: 4,
                    color: Colors.deepPurple,
                  )),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('Upload Images!'),
                  onTap: () {
                    Navigator.of(context)
                        .popAndPushNamed(UpdateScreen.routename);
                  },
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    width: 4,
                    color: Colors.deepPurple,
                  )),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('Face Verification!'),
                  onTap: () {
                    Navigator.of(context)
                        .popAndPushNamed(FaceRecognitionScreen.routename);
                  },
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    width: 4,
                    color: Colors.deepPurple,
                  )),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Upload Voice!'),
                  onTap: () {
                    Navigator.of(context)
                        .popAndPushNamed(UpdateVoiceScreen.routename);
                  },
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    width: 4,
                    color: Colors.deepPurple,
                  )),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('Voice Verification!'),
                  onTap: () {
                    Navigator.of(context)
                        .popAndPushNamed(VoiceVerificationScreen.routename);
                  },
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    width: 4,
                    color: Colors.deepPurple,
                  )),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('Home!'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    width: 4,
                    color: Colors.deepPurple,
                  )),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('User Details!'),
                  onTap: () {
                    Navigator.of(context)
                        .popAndPushNamed(UserDetails.routename);
                  },
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    width: 4,
                    color: Colors.deepPurple,
                  )),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Signature!'),
                  onTap: () {
                    Navigator.of(context)
                        .popAndPushNamed(SignatureScreen.routename);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
