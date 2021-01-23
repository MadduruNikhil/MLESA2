import 'dart:convert';

import 'package:flutter/material.dart';

import 'dart:typed_data';

import 'package:hand_signature/signature.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/SideDrawer.dart';

ValueNotifier<ByteData> rawImage = ValueNotifier<ByteData>(null);

class SignatureScreen extends StatefulWidget {
  static const routename = './SignaturePad';
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final signdetailskey = GlobalKey<ScaffoldState>();

  HandSignatureControl control = new HandSignatureControl(
    threshold: 5.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  void uploadsign() async {
    if (rawImage.value != null) {
      String signEncoded = base64.encode(rawImage.value.buffer.asUint8List());
      await Firestore.instance
          .document('Users/${_user.uid}/Signature/${_user.uid}')
          .setData(
        {'signMapEncoded': signEncoded},
      );
      signdetailskey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Theme.of(context).primaryColor,
          content: Text('Sign Uploaded'),
        ),
      );
    } else {
      signdetailskey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Theme.of(context).errorColor,
          content: Text('Export the Image first!'),
        ),
      );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Signature',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      key: signdetailskey,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('./assets/images/Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        width: devicesize.width,
        height: devicesize.height,
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment(0, -0.8),
                child: RaisedButton(
                  padding: EdgeInsets.all(15),
                  color: Colors.amber,
                  onPressed: () {
                    uploadsign();
                  },
                  child: Text('Upload'),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.750,
                        child: Stack(
                          children: [
                            Container(
                              constraints: BoxConstraints.expand(),
                              color: Colors.white,
                              child: HandSignaturePainterView(
                                control: control,
                                type: SignatureDrawType.shape,
                              ),
                            ),
                            CustomPaint(
                              painter: DebugSignaturePainterCP(
                                control: control,
                                cpEnd: false,
                                cpStart: false,
                                cp: false,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: devicesize.width / 40,
                      ),
                      RaisedButton(
                        color: Colors.amber,
                        onPressed: control.clear,
                        child: Text('Clear'),
                      ),
                      SizedBox(
                        width: devicesize.width / 40,
                      ),
                      RaisedButton(
                        color: Colors.amber,
                        onPressed: () async {
                          rawImage.value = await control.toImage(
                            color: Colors.blueAccent,
                          );
                        },
                        child: Text('Export'),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildImageview(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildImageview() => Container(
      margin: EdgeInsets.only(bottom: 5),
      width: 192.0,
      height: 96.0,
      decoration: BoxDecoration(
        border: Border.all(),
        color: Colors.white,
      ),
      child: ValueListenableBuilder<ByteData>(
        valueListenable: rawImage,
        builder: (context, data, child) {
          if (data == null) {
            return Container(
              color: Colors.amber,
              child: Center(
                child: Text('Not Signed Yet!'),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.memory(data.buffer.asUint8List()),
            );
          }
        },
      ),
    );
