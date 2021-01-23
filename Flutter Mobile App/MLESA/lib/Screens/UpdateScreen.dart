import 'dart:async';

import 'package:MLESA/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/SideDrawer.dart';

class UpdateScreen extends StatefulWidget {
  static const routename = './UpdateImagesScreen';
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final updateglobalKey = GlobalKey<ScaffoldState>();

  File _leftImage;
  File _rightImage;
  File _frontImage;
  // ignore: unused_field
  File _defaultImage;
  var _left = false;
  var _right = false;
  var _front = false;
  final picker = ImagePicker();

  bool checkDataUpload() {
    if (!_left) {
      return false;
    }
    if (!_right) {
      return false;
    }
    if (!_front) {
      return false;
    }
    return true;
  }

  Future<void> sendData() async {
    if (!checkDataUpload()) {
      print('got not');
      // ignore: deprecated_member_use
      updateglobalKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
          content: Text('Cannot Upload!'),
        ),
      );
      return;
    }
     Timer(Duration(seconds: 2), ()  {
         Navigator.of(context).pushNamed(HomeScreen.routename);
      });

    var leftData = _leftImage.readAsBytesSync();
    var rightData = _rightImage.readAsBytesSync();
    var frontData = _frontImage.readAsBytesSync();
    String leftEncoded = base64.encode(leftData);
    String rightEncoded = base64.encode(rightData);
    String frontEncoded = base64.encode(frontData);
    await Firestore.instance
        .document('Users/${_user.uid}/FaceMapping/${_user.uid}')
        .updateData(
      {
        'UploadedImage': true,
        'LeftImageData': leftEncoded,
        'RightImageData': rightEncoded,
        'FrontImageData': frontEncoded,
      },
    ).catchError(
      (error) {
        if (error != null) {
          print(error);
          return;
        }
      },
    );
    // ignore: deprecated_member_use
    updateglobalKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
        content: Text(' Uploaded!'),
      ),
    );
  }

  Future<void> getImagedata(String side) async {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 500,
      maxWidth: 500,
    );
    setState(
      () {
        if (pickedFile != null) {
          switch (side) {
            case 'Left':
              _leftImage = File(pickedFile.path);
              break;
            case 'Right':
              _rightImage = File(pickedFile.path);
              break;
            case 'Front':
              _frontImage = File(pickedFile.path);
              break;
            default:
              _defaultImage = File(pickedFile.path);
          }
        } else {
          print('No image selected.');
        }
      },
    );
  }

  void update(String side) async {
    await getImagedata(side);
    if (side == 'Left') {
      if (_leftImage != null) {
        setState(
          () {
            _left = true;
          },
        );
      }
    }
    if (side == 'Right') {
      if (_rightImage != null) {
        setState(
          () {
            _right = true;
          },
        );
      }
    }
    if (side == 'Front') {
      if (_frontImage != null) {
        setState(() {
          _front = true;
        });
      }
    }
  }

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
      key: updateglobalKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Image Upload.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              padding: EdgeInsets.all(16),
              icon: Icon(Icons.help_outline_outlined),
              onPressed: () {
                updateglobalKey.currentState.showBottomSheet((context) {
                  return Container(
                    height: 450,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('./assets/images/Background.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            alignment: Alignment.center,
                            color: Colors.deepPurple,
                            height: 40,
                            width: 150,
                            child: Text(
                              'Upload - Status!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        (_left)
                            ? Card(
                                color: Colors.pinkAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    ' Left Imprint <=> Left is Uploaded',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Card(
                                color: Colors.pinkAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Left Imprint <=> Upload Pending..',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                        SizedBox(height: 10),
                        (_right)
                            ? Card(
                                color: Colors.pinkAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    ' Right Imprint <=> Right is Uploaded',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Card(
                                color: Colors.pinkAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Right Imprint <=> Upload Pending..',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                        SizedBox(height: 10),
                        (_front)
                            ? Card(
                                color: Colors.pinkAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    ' Front Imprint <=> Front is Uploaded',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Card(
                                color: Colors.pinkAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Front Imprint <=> Upload Pending..',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 30,
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 10,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          color: Colors.indigo,
                          child: Text(
                            'Close',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  );
                });
              }),
        ],
      ),
      body: Container(
        height: devicesize.height,
        width: devicesize.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple,
              Colors.pink,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 350,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            tileColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: Icon(
                              Icons.tag_faces_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                            title: Text(
                              'Left imprint!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Scan Facing Left Sided!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: (!_left)
                                ? Icon(
                                    Icons.upload_file,
                                    color: Colors.amber,
                                  )
                                : Icon(
                                    Icons.turned_in,
                                    color: Colors.green,
                                  ),
                            onTap: () {
                              update('Left');
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            tileColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: Icon(
                              Icons.tag_faces_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                            title: Text(
                              'Right imprint!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Scan Facing Right Sided!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: (!_right)
                                ? Icon(
                                    Icons.upload_file,
                                    color: Colors.amber,
                                  )
                                : Icon(
                                    Icons.turned_in,
                                    color: Colors.green,
                                  ),
                            onTap: () {
                              update('Right');
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            tileColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: Icon(
                              Icons.tag_faces_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                            title: Text(
                              'Front imprint!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Scan Facing Front Sided!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: (!_front)
                                ? Icon(
                                    Icons.upload_file,
                                    color: Colors.amber,
                                  )
                                : Icon(
                                    Icons.turned_in,
                                    color: Colors.green,
                                  ),
                            onTap: () {
                              update('Front');
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.orangeAccent, width: 4),
              ),
              color: Colors.deepPurple,
              onPressed: () async {
                await sendData();
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Upload!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
