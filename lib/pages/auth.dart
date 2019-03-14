import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/main.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  bool _switchValue = false;
  final Map<String, dynamic> _formData = {"email": null, "password": null};
  final GlobalKey<FormState> _authForm = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  void _submitForm(Function authenticate) async {
    if (!_authForm.currentState.validate()) {
      return;
    }
    Map<String, dynamic> successInfo;
    _authForm.currentState.save();
    successInfo = await authenticate(
        _formData['email'], _formData['password'], _authMode);
    if (successInfo['success']) {
      // Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error!'),
            content: Text(successInfo['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('OKAY'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "E-mail",
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return "This field cannot be empty";
        }
      },
      onSaved: (String value) {
        _formData["email"] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordTextController,
      decoration: InputDecoration(
        labelText: "Password",
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return "This field cannot be empty";
        }
      },
      onSaved: (String value) {
        _formData["password"] = value;
      },
      obscureText: true,
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return _authMode == AuthMode.Login
        ? Container()
        : TextFormField(
            decoration: InputDecoration(
              labelText: "Confirm Password",
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (String value) {
              if (_passwordTextController.text != value) {
                return "Passwords do not match";
              }
            },
            obscureText: true,
          );
  }

  Widget _buildToggleAuthModeButton() {
    return FlatButton(
      child: Text(
        'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}',
        style: TextStyle(color: Colors.lightBlue),
      ),
      onPressed: () {
        setState(() {
          _authMode =
              _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
        });
      },
    );
  }

  Widget _buildAuthButtonBar() {
    return ButtonBar(
      children: <Widget>[
        _buildToggleAuthModeButton(),
        ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
            return model.isLoading
                ? CircularProgressIndicator()
                : RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      _authMode == AuthMode.Login ? "LOGIN" : "SIGNUP",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _submitForm(model.authenticate),
                  );
          },
        ),
      ],
    );
  }

  Widget _buildLoginFormCard(BuildContext context) {
    return Card(
      elevation: 16.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.bottomLeft,
            end: FractionalOffset.topRight,
            colors: [const Color(0xFFFFFFFF), const Color(0xFFF1F1F1)],
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _authForm,
          child: Column(
            children: <Widget>[
              _buildEmailTextField(),
              SizedBox(
                height: 10.0,
              ),
              _buildPasswordTextField(),
              SizedBox(
                height: 10.0,
              ),
              _buildPasswordConfirmTextField(),
              SwitchListTile(
                title: Text(
                  "Accept Terms",
                ),
                activeColor: Theme.of(context).primaryColorDark,
                value: _switchValue,
                onChanged: (bool value) {
                  setState(() {
                    _switchValue = value;
                  });
                },
              ),
              _buildAuthButtonBar(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: targetWidth,
              child: _buildLoginFormCard(context),
            ),
          ),
        ),
      ),
    );
  }
}
