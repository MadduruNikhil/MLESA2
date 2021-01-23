import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:file/file.dart';
import 'dart:io' as IO;
import 'package:file/local.dart';
import 'package:convert/convert.dart';

import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';

import './HomeScreen.dart';

class VoiceVerificationScreen extends StatefulWidget {
  static const routename = './VoiceVerification';
  final LocalFileSystem localFileSystem;

  VoiceVerificationScreen({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  @override
  _VoiceVerificationScreenState createState() =>
      _VoiceVerificationScreenState();
}

class _VoiceVerificationScreenState extends State<VoiceVerificationScreen> {
  final verifyVoiceglobalKey = GlobalKey<ScaffoldState>();
  FirebaseUser _user;

  File file;
  FlutterAudioRecorder _recorder;
  AudioPlayer audioPlayer = AudioPlayer();
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  bool uploadedVoice = false;

  // var _verification = false;
  // var _loading = false;
  var _recording = false;

  Future<void> _initiate() async {
    try {
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
        _recorder = FlutterAudioRecorder(
          customPath,
          audioFormat: AudioFormat.WAV,
          sampleRate: 16000,
        );

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
    var result = await _recorder.stop();
    file = widget.localFileSystem.file(result.path);
    verifyVoiceglobalKey.currentState.showSnackBar(
      SnackBar(
        content: (file != null)
            ? Text('Recorded! You can Verify')
            : Text('Record Again!'),
      ),
    );
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
    setState(
      () {
        _recording = true;
      },
    );

    Timer(
      Duration(seconds: 6),
      () {
        _stop();
        if (!mounted) {
          return;
        }
        setState(
          () {
            _recording = false;
          },
        );
      },
    );
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

  Future<void> verifyVoice() async {
    var data = file.readAsBytesSync();
    final String profileId = await getProfileId();
    final url =
        'https://westus.api.cognitive.microsoft.com//speaker/verification/v2.0/text-independent/profiles/$profileId/verify';

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Ocp-Apim-Subscription-Key": "6c66a2e5fe1c4a68a401fa1967012192",
      },
      body: json.encode(
        {
          "audioData": hex.encode(data),
        },
      ),
    );
    print(response.body);
    await Firestore.instance
        .document('Users/${_user.uid}/VoiceMapping/${_user.uid}')
        .updateData(
      {
        'VoiceData': hex.encode(data),
      },
    ).catchError(
      (error) {
        if (error != null) {
          print(error);
          return;
        }
      },
    );
    Map<String, dynamic> verifiedData = json.decode(response.body);
    showDialog(
      builder: (ctx) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).popAndPushNamed(HomeScreen.routename);
          },
          child: Dialog(
            child: Container(
              child: (verifiedData == null)
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        Text(
                          verifiedData.toString(),
                        ),
                        Center(
                          child:
                              (verifiedData['recognitionResult'] == 'Accept' &&
                                      verifiedData['score'] >= 0.75)
                                  ? Icon(
                                      Icons.verified,
                                    )
                                  : Icon(
                                      Icons.not_interested,
                                    ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
      context: context,
    );
  }

  _initUser() async {
    _user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot doc = await Firestore.instance
        .document('Users/${_user.uid}/VoiceMapping/${_user.uid}')
        .get();
    if (!mounted) {
      return;
    }
    setState(
      () {
        uploadedVoice = doc.data['UploadedVoice'];
      },
    );
    print(uploadedVoice);
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

  @override
  Widget build(BuildContext context) {
    final devicesize = MediaQuery.of(context).size;
    return Scaffold(
      key: verifyVoiceglobalKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Voice Verify!!',
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
            Container(
              alignment: Alignment.center,
              width: devicesize.width,
              height: 70,
              color: Colors.amber,
              child: _recording
                  ? Text('${6 - _current.duration.inSeconds}')
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
                    onPressed: () {
                      recordVoice();
                    },
                    child: Text(
                      'Record!',
                      style: TextStyle(
                          color: Colors.yellow, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  RaisedButton(
                    color: Colors.black,
                    onPressed: () async {
                      // ignore: deprecated_member_use
                      verifyVoiceglobalKey.currentState.showSnackBar(
                        SnackBar(
                          content: Center(
                            child: CircularProgressIndicator(),
                          ),
                          duration: Duration(seconds: 5),
                        ),
                      );
                      await verifyVoice();
                      _initiate();
                    },
                    child: Text(
                      'Verify!',
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
                'Sing Something for 12 seconds \n or \n Satyameva Jayathe \n Vasui daika Kutumbam \n',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
