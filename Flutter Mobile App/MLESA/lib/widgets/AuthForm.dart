import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isloading);

  final bool isloading;

  final void Function(String email, String userName, String passWord,
      bool isLogin, BuildContext context) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formkey = GlobalKey<FormState>();
  var _islogin = true;
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';

  

  void _trySubmit(BuildContext context) {
    final isValid = _formkey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formkey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userName.trim(),
        _userPassword.trim(),
        _islogin,
        context,
      );

      // use those values to send Auth Requests ..
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: ValueKey('Email'),
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Please Provide an Valid Email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email Address'),
                  onSaved: (value) {
                    _userEmail = value;
                  },
                ),
                if (!_islogin)
                  TextFormField(
                    key: ValueKey('UserName'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 5) {
                        return 'Please Enter Atleast  5 Characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'User Name'),
                    onSaved: (value) {
                      _userName = value;
                    },
                  ),
                TextFormField(
                  key: ValueKey('PassWord'),
                  validator: (value) {
                    if (value.isEmpty || value.length < 8) {
                      return 'Please Provide a Password with 8 Characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSaved: (value) {
                    _userPassword = value;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                if (widget.isloading)
                  Container(
                    margin: EdgeInsets.all(30),
                    height: 35,
                    width: 35,
                    child: CircularProgressIndicator(),
                  ),
                if (!widget.isloading)
                  RaisedButton(
                    color: Colors.amber,
                    onPressed: () {
                      _trySubmit(context);
                    },
                    child: Text(_islogin ? 'Log-In' : 'Sign-Up',),
                  ),
                if (!widget.isloading)
                  FlatButton(
                    textColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      setState(() {
                        _islogin = !_islogin;
                      });
                    },
                    child: Text(
                      _islogin
                          ? 'Create a New Account!'
                          : 'Well I have An Account Already!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
