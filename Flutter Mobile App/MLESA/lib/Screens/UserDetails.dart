import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './HomeScreen.dart';

class UserDetails extends StatefulWidget {
  static const routename = './userDetails';
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final userdetailskey = GlobalKey<ScaffoldState>();

  final _formkey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _dob = '';
  String _gender = 'Male';
  String _mobile = '';
  String _aadhar = '';

  TextStyle style1 = TextStyle(fontWeight: FontWeight.bold);
  DateTime pickeddate;

  void _presentdate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    ).then(
      (value) {
        setState(() {
          pickeddate = value;
          _dob = DateFormat.yMMMMEEEEd().format(value);
        });
      },
    );
  }

  void submit() async {
    final isValid = _formkey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (pickeddate == null) {
      userdetailskey.currentState.showSnackBar(
        SnackBar(
          content: Text('Select DOB'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
    if (isValid && pickeddate != null) {
      _formkey.currentState.save();
      await Firestore.instance
          .collection('Users')
          .document(_user.uid)
          .updateData(
        {
          'First Name': _firstName.trim(),
          'Last Name': _lastName.trim(),
          'DOB': _dob,
          'Mobile': _mobile.trim(),
          'AAdhar': _aadhar.trim(),
          'Gender': _gender.trim(),
        },
      );
      Navigator.of(context).popAndPushNamed(HomeScreen.routename);
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
      key: userdetailskey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
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
            Center(
              child: Card(
                color: Colors.amber,
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: devicesize.width / 2.75,
                              child: TextFormField(
                                key: ValueKey('First Name'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please Provide an Valid First name';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  labelStyle: style1,
                                ),
                                onSaved: (value) {
                                  _firstName = value;
                                },
                              ),
                            ),
                            SizedBox(
                              width: devicesize.width / 2.75,
                              child: TextFormField(
                                key: ValueKey('Last Name'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please Provide an Valid last Name';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  labelStyle: style1,
                                  hintStyle: style1,
                                ),
                                onSaved: (value) {
                                  _lastName = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                              labelText: 'Gender', labelStyle: style1),
                          validator: (value) {
                            if (value == null) {
                              return 'Please Provide Your Gender';
                            }
                            return null;
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _gender = value;
                            });
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'D O B : ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w400),
                            ),
                            (pickeddate == null)
                                ? Text(
                                    'Choose a date!',
                                    style: TextStyle(fontSize: 20),
                                  )
                                : Text(
                                    DateFormat.yMd().format(pickeddate),
                                    style: TextStyle(fontSize: 20),
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: IconButton(
                                icon: Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.black,
                                  size: 30,
                                ),
                                onPressed: () {
                                  _presentdate();
                                },
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          key: ValueKey('Mobile'),
                          validator: (value) {
                            if (value.isEmpty || value.length != 10) {
                              return 'Please Provide an Valid Mobile number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Mobile',
                            labelStyle: style1,
                          ),
                          onSaved: (value) {
                            _mobile = value;
                          },
                        ),
                        TextFormField(
                          key: ValueKey('AAdhar No'),
                          validator: (value) {
                            if (value.isEmpty || value.length != 12) {
                              return 'Please Provide an Valid AAdhar number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'AAdhar No',
                            labelStyle: style1,
                          ),
                          onSaved: (value) {
                            _aadhar = value;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            RaisedButton(
              padding: const EdgeInsets.all(15.0),
              onPressed: () {
                submit();
              },
              color: Colors.amber,
              child: Text('Save Details!'),
            )
          ],
        ),
      ),
    );
  }
}
