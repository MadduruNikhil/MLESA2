import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file/file.dart';
import 'dart:io' as IO;
import 'package:file/local.dart';



import 'package:path_provider/path_provider.dart';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/SideDrawer.dart';

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
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  // var _verification = false;
  // var _loading = false;
  var _recording = false;

  _initiate() async {
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
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
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
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
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
    print(file.path);
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
    print(_current.status);
  }

  void recordVoice() async {
    _start();
    setState(() {
      _recording = true;
    });

    Timer(Duration(seconds: 3), () {
      _stop();
      setState(() {
        _recording = false;
      });
    });
    print(_currentStatus);
    updateVoiceglobalKey.currentState.showSnackBar(
      SnackBar(
        content: (file.readAsBytesSync().isNotEmpty)
            ? Text('Recorded! You can upload')
            : Text('Record Again!'),
      ),
    );
  }

  void upload() async {
    var bytes = file.readAsBytesSync();
    String voiceEncoded = base64.encode(bytes);
    print(file.path);

    await Firestore.instance
        .document('Users/${_user.uid}/VoiceMapping/${_user.uid}')
        .updateData(
      {
        'UploadedVoice': true,
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
    updateVoiceglobalKey.currentState.showSnackBar(
      SnackBar(
        content: 
             Text('Voice Uploaded')
           
      ),
    );
  }

  @override
  void initState() {
    
    super.initState();
    _initiate();
    _initUser();
  }

  Future<void> _initUser() async {
    _user = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    final devicesize = MediaQuery.of(context).size;
    return Scaffold(
      drawer: SideDrawer(),
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
              width: devicesize.width,
              height: 70,
              color: Colors.amber,
              child: Icon(
                _recording ? Icons.mic_off : Icons.mic,
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
                    onPressed: () {
                      upload();
                    },
                    child: Text(
                      'Upload!',
                      style: TextStyle(
                        color: Colors.yellow,
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
              height: 40,
              width: devicesize.width,
              color: Colors.amber,
              child: Text(
                'Say - hello India!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
