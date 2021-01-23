import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/SideDrawer.dart';
import './HomeScreen.dart';

class FaceRecognitionScreen extends StatefulWidget {
  static const routename = './FaceVerificationScreen';
  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  final picker = ImagePicker();
  File _image;
  var loading = true;

  Future<Map<String, dynamic>> faceverification() async {
    DocumentSnapshot doc = await Firestore.instance
        .document('Users/${_user.uid}/FaceMapping/${_user.uid}')
        .get();
    const url = 'http://34.121.145.40:5500/VerifyFace';
    if (_image == null) {
      // ignore: deprecated_member_use
      verifyglobalKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
          content: Text('Cannot Upload!'),
        ),
      );
      return null;
    } else {
      var imageData = _image.readAsBytesSync();
      String imageEncoded = base64.encode(imageData);
      await Firestore.instance
          .document('Users/${_user.uid}/FaceMapping/${_user.uid}')
          .updateData(
        {'VerifyImageData': imageEncoded},
      );
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            'UserID': _user.uid,
            'leftImageData': doc.data['LeftImageData'],
            'rightImageData': doc.data['RightImageData'],
            'frontImageData': doc.data['FrontImageData'],
            'verifyImageData': imageEncoded,
          },
        ),
      );
      return json.decode(response.body);
    }
  }

  Future<void> getImageData() async {
    final pickedFile = await picker.getImage(
      maxHeight: 500,
      maxWidth: 500,
      source: ImageSource.camera,
    );

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  final verifyglobalKey = GlobalKey<ScaffoldState>();

  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    _user = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    final devicesize = MediaQuery.of(context).size;
    return Scaffold(
      key: verifyglobalKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Face Verification.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        height: devicesize.height,
        width: devicesize.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('./assets/images/Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 100,
              color: Colors.amber,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: (_image == null)
                        ? Icon(
                            Icons.face_unlock_sharp,
                            size: 40,
                          )
                        : Image.file(
                            _image,
                          ),
                  ),
                  InkWell(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera,
                            size: 30,
                          ),
                          SizedBox(height: 10),
                          Text('Click Me!')
                        ],
                      ),
                    ),
                    onTap: () {
                      getImageData();
                    },
                  )
                ],
              ),
            ),
            SizedBox(height: 40),
            InkWell(
                child: Container(
                  padding: EdgeInsets.all(30),
                  alignment: Alignment.center,
                  width: double.infinity,
                  color: Colors.amber,
                  child: Text('Verify!'),
                ),
                onTap: () async {
                  // ignore: deprecated_member_use
                  verifyglobalKey.currentState.showSnackBar(
                    SnackBar(
                      content: Center(
                        child: CircularProgressIndicator(),
                      ),
                      duration: Duration(seconds: 30),
                    ),
                  );
                  Map<String, dynamic> results = await faceverification();
                  if (results['status']) {
                    print(results);
                    var distance = results['pair_1'];
                    var legsidedistance = results['pair_2'];
                    var offsidedistance = results['pair_3'];
                    showDialog(
                      barrierDismissible: false,
                      builder: (ctx) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Dialog(
                            child: Container(
                              child: Center(
                                child: ((distance <= 0.25 &&
                                        legsidedistance <= 0.4 &&
                                        offsidedistance <= 0.4))
                                    ? Icon(
                                        Icons.verified,
                                      )
                                    : Icon(
                                        Icons.not_interested,
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                      context: context,
                    );
                  } else {
                    showDialog(
                      barrierDismissible: false,
                      builder: (ctx) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .popAndPushNamed(HomeScreen.routename);
                          },
                          child: Dialog(
                            child: Container(
                              child: Center(
                                child: Text(
                                  results['Message'],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      context: context,
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}
