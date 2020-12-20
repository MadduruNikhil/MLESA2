Dependencies 

	image_picker: ^0.6.7+11
 	camera: ^0.5.8+7
  	http: ^0.12.2
  	flutter_audio_recorder: ^0.5.5
  	path_provider: ^1.6.21
  	intl: ^0.16.1
	hand_signature: ^0.6.3
	cupertino_icons: ^0.1.3
  	cloud_firestore: ^0.13.5
  	firebase_auth: ^0.16.0

	Reference = https://pub.dev/

Actions Required for API Deployment are nullified in the application.

	API Face Verifiaction :
	
	Path1 = ./MLESA/lib/Screens/FaceRecognitionScreen.dart
	function = faceverifiaction()
	line to add the api = 26
	after adding comment out the section from 179 to 205 lines

	API Voice Verification :
	
	Path2 = ./MLESA/lib/Screens/VoiceVerification.dart
	function = verifyVoice()
	line to add the api = 144
	after adding the api refer the function in the line 284 under the button widget.