import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './FaceRecognitionScreen.dart';
import './UpdateScreen.dart';
import './VoiceVerification.dart';
import './UpdateVoiceScreen.dart';

import '../widgets/SideDrawer.dart';

class HomeScreen extends StatefulWidget {
  static const routename = './HomeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeglobalKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final devicesize = MediaQuery.of(context).size;
    return Scaffold(
      key: homeglobalKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.isCurrent,
              );
              FirebaseAuth.instance.signOut();
            },
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: SideDrawer(),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return CircularProgressIndicator();
          } else {
            return Container(
              alignment: Alignment.center,
              height: devicesize.height,
              width: devicesize.width,
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
                    InkWell(
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .document(
                                'Users/${snapshot.data.uid}/VoiceMapping/${snapshot.data.uid}')
                            .snapshots()
                            .asBroadcastStream(),
                        builder: (ctx, dataSnapshot) {
                          if (dataSnapshot.connectionState ==
                                  ConnectionState.waiting ||
                              dataSnapshot.hasError) {
                            return CircularProgressIndicator();
                          }
                          if (dataSnapshot.hasData) {
                            DocumentSnapshot snapdata = dataSnapshot.data;
                            if (!snapdata.exists) {
                              return CircularProgressIndicator();
                            }
                            return Card(
                              color: Colors.amber,
                              child: Container(
                                alignment: Alignment.center,
                                height: devicesize.height / 15,
                                width: devicesize.width / 2,
                                child: InkWell(
                                  child: Text(
                                    (snapdata['UploadedVoice'])
                                        ? 'Try Voice Verification!'
                                        : 'Upload Your Voice Data!',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Card(
                            child: Text('Loading'),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .document(
                                'Users/${snapshot.data.uid}/FaceMapping/${snapshot.data.uid}')
                            .snapshots()
                            .asBroadcastStream(),
                        builder: (ctx, dataSnapshot) {
                          if (dataSnapshot.connectionState ==
                                  ConnectionState.waiting ||
                              dataSnapshot.hasError) {
                            return CircularProgressIndicator();
                          }
                          if (dataSnapshot.hasData) {
                            DocumentSnapshot snapdata = dataSnapshot.data;
                            if (!snapdata.exists) {
                              return CircularProgressIndicator();
                            }
                            return Card(
                              color: Colors.amber,
                              child: Container(
                                alignment: Alignment.center,
                                height: devicesize.height / 15,
                                width: devicesize.width / 2,
                                child: InkWell(
                                  child: Text(
                                    (snapdata['UploadedImage'])
                                        ? 'Try Face Verification!'
                                        : 'Upload Your FaceData!',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Card(
                            child: Text('Loading'),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 150,
                          width: devicesize.width / 2.8,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.face,
                                  size: 38,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Face!',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          height: 150,
                          width: devicesize.width / 2.8,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.keyboard_voice,
                                  size: 38,
                                ),
                                SizedBox(height: 10),
                                GestureDetector(
                                  onVerticalDragEnd: (value) {
                                    homeglobalKey.currentState.showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('!DEVELOPED BY MSCN!')));
                                  },
                                  child: Text(
                                    'Voice!',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
