import 'dart:convert';
import 'package:MLESA/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file/file.dart';
import 'dart:io' as IO;

import 'package:convert/convert.dart';

import 'package:file/local.dart';

import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/SideDrawer.dart';

import '../Screens/VoiceVerification.dart';

class UpdateVoiceScreen extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  UpdateVoiceScreen({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  static const routename = './UploadVoice';
  @override
  _UpdateVoiceScreenState createState() => _UpdateVoiceScreenState();
}

class _UpdateVoiceScreenState extends State<UpdateVoiceScreen> {
  final updateVoiceglobalKey = GlobalKey<ScaffoldState>();
  FirebaseUser _user;

  File file;
  FlutterAudioRecorder _recorder;
  AudioPlayer audioPlayer = AudioPlayer();
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  // var _verification = false;
  // var _loading = false;
  var _recording = false;

  Future<void> _initiate() async {
    try {
      if (!mounted) {
        return;
      }
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/audio';
        IO.Directory appDocDirectory;
        if (IO.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString() +
            '.wav';
        print(customPath);
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        if (!mounted) {
          return;
        }
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        Scaffold.of(context).showSnackBar(
          new SnackBar(
            content: new Text("You must accept permissions"),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    if (!mounted) {
      return;
    }
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      if (!mounted) {
        return;
      }
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        if (!mounted) {
          return;
        }
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
      print(_current.status);
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    if (!mounted) {
      return;
    }
    var result = await _recorder.stop();
    file = widget.localFileSystem.file(result.path);
    updateVoiceglobalKey.currentState.showSnackBar(
      SnackBar(
        content: (file != null)
            ? Text('Recorded! You can upload')
            : Text('Record Again!'),
      ),
    );
    print(file.path);
    print("File length: ${await file.length()}");
    if (!mounted) {
      return;
    }
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
    print(_current.status);
  }

  Future<void> recordVoice() async {
    await _initiate();
    _start();
    if (!mounted) {
      return;
    }
    setState(() {
      _recording = true;
    });

    Timer(Duration(seconds: 15), () {
      _stop();

      if (!mounted) {
        return;
      }
      setState(() {
        _recording = false;
      });
    });
    print(_currentStatus);
  }

  void onPlayAudio() async {

    await audioPlayer.play(_current.path, isLocal: true);
  }

  Future<String> getProfileId() async {
    DocumentSnapshot doc = await Firestore.instance
        .document('Users/${_user.uid}/VoiceMapping/${_user.uid}')
        .get();
    return doc.data['VoiceProfileID'];
  }

  Future<void> re_upload(bool uploadedstatus) async {
    print(uploadedstatus);
    var bytes = file.readAsBytesSync();
    String voiceEncoded = hex.encode(bytes);
    await Firestore.instance
        .document('Users/${_user.uid}/VoiceMapping/${_user.uid}')
        .updateData(
      {
        'UploadedVoice': uploadedstatus,
        'UploadedVoiceData': voiceEncoded,
      },
    ).catchError(
      (error) {
        if (error != null) {
          print(error);
          return;
        }
      },
    );
  }

  Future<Map<String, dynamic>> upload() async {
    var bytes = file.readAsBytesSync();
    String voiceEncoded = hex.encode(bytes);
    final String profileId = await getProfileId();
    final url =
        'https://westus.api.cognitive.microsoft.com//speaker/verification/v2.0/text-independent/profiles/$profileId/enrollments';
    final response = await http.post(
      url,
      headers: {
        "Content-Type": 'application/json',
        "Ocp-Apim-Subscription-Key": "6c66a2e5fe1c4a68a401fa1967012192",
      },
      body: json.encode(
        {
          "audioData": voiceEncoded,
        },
      ),
    );
    print(response.body);
    Map<String, dynamic> data = json.decode(response.body);

    updateVoiceglobalKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          'Voice Uploaded',
        ),
      ),
    );
    return data;
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    if (mounted) {
      _recorder.stop();
    }
  }

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
      key: updateVoiceglobalKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Voice Upload',
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
          children: [
            Text(
              'It Is good to Upload Lot of voice Data for Better Efficiency!',
            ),
            Container(
              alignment: Alignment.center,
              width: devicesize.width,
              height: 70,
              color: Colors.amber,
              child: _recording
                  ? Text('${15 - _current.duration.inSeconds}')
                  : Text('Need to Upload total of 20 Seconds of Data'),
            ),
            Container(
              width: devicesize.width,
              height: 70,
              color: Colors.amber,
              child: Icon(
                _recording ? Icons.mic : Icons.mic_off,
                size: 50,
              ),
            ),
            Container(
              width: devicesize.width,
              height: 70,
              color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    color: Colors.black,
                    onPressed: () async {
                      await recordVoice();
                    },
                    child: Text(
                      'Record!',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  RaisedButton(
                    color: Colors.black,
                    onPressed: () async {
                      showDialog(
                        useRootNavigator: true,
                        barrierDismissible: false,
                        useSafeArea: false,
                        context: context,
                        builder: (_) {
                          return Dialog(
                            child: FutureBuilder(
                              future: upload(),
                              builder: (ctx, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snap.connectionState ==
                                        ConnectionState.done &&
                                    snap != null) {
                                  var data = snap.data;
                                  return Container(
                                    height: devicesize.height,
                                    width: devicesize.width,
                                    child: (data == null)
                                        ? Center(
                                            child: Column(
                                              children: [
                                                Text(
                                                    'Audio Is Too Noisy!\nTry Again!'),
                                              ],
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Status : ${data['enrollmentStatus']}",
                                              ),
                                              Text(
                                                "UploadCount : ${data['enrollmentsCount']}",
                                              ),
                                              Text(
                                                "More Time to Upload : ${data['remainingEnrollmentsSpeechLength']}",
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  RaisedButton(
                                                    child: Text(
                                                      (data['enrollmentStatus'] ==
                                                              'Enrolled')
                                                          ? 'Now VerifY!'
                                                          : 'Re-Upload',
                                                    ),
                                                    onPressed: () async {
                                                      if (data[
                                                              'enrollmentStatus'] ==
                                                          'Enrolled') {
                                                        await re_upload(true);
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .popAndPushNamed(
                                                                VoiceVerificationScreen
                                                                    .routename);
                                                      } else {
                                                        re_upload(false);
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .popAndPushNamed(
                                                          HomeScreen.routename,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                  );
                                } else {
                                  return LinearProgressIndicator();
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      'Upload!',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FlatButton(
                    
                    onPressed: onPlayAudio,
                    child: Text(
                      "Play",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              alignment: Alignment.center,
              height: 120,
              width: devicesize.width,
              color: Colors.amber,
              child: Text(
                'Sing Something for 20 seconds\nor\nSatyameva Jayathe \nVasuidaika Kutumbam\n',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
