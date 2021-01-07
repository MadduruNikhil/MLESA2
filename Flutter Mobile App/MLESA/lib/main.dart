import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './Screens/UpdateScreen.dart';
import './Screens/AuthScreen.dart';
import './Screens/ResetPassword.dart';
import './Screens/FaceRecognitionScreen.dart';
import './Screens/UpdateVoiceScreen.dart';
import './Screens/VoiceVerification.dart';
import './Screens/HomeScreen.dart';
import './Screens/UserDetails.dart';
import './Screens/SignatureScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      new Home(),
    );
  });
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, userSnapShot) {
          if (userSnapShot.connectionState == ConnectionState.waiting ||
              userSnapShot.hasError) {
            return CircularProgressIndicator();
          }
          if (userSnapShot.hasData) {
            return HomeScreen();
          }
          return AuthScreen();
        },
      ),
      routes: {
        HomeScreen.routename: (_) => HomeScreen(),
        UpdateScreen.routename: (_) => UpdateScreen(),
        FaceRecognitionScreen.routename: (_) => FaceRecognitionScreen(),
        UpdateVoiceScreen.routename: (_) => UpdateVoiceScreen(),
        VoiceVerificationScreen.routename: (_) => VoiceVerificationScreen(),
        ResetPassword.routename: (_) => ResetPassword(),
        AuthScreen.routename: (_) => AuthScreen(),
        UserDetails.routename: (_) => UserDetails(),
        SignatureScreen.routename: (_) => SignatureScreen(),
      },
    );
  }
}
