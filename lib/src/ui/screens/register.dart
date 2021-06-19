import 'package:flutter/material.dart';
import 'package:flutter_app1/src/blocs/user/login_bloc.dart';
import 'package:flutter_app1/src/blocs/user/login_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          margin: EdgeInsets.all(16.0),
          child: Column(
            children: [
              new Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(
                            "https://i.pinimg.com/originals/7c/c7/a6/7cc7a630624d20f7797cb4c8e93c09c1.png",
                          )))),
              SizedBox(height: 16.0),
              MyCustomForm(),
            ],
          ),
        ),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isDialogShowing = false;

  LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();

    loginBloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _firstNameController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'First Name',
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(8.0),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(8.0),
                borderSide: new BorderSide(),
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter valid Name';
              }
              return null;
            },
          ),
          SizedBox(
            height: 16.0,
          ),
          TextFormField(
            controller: _lastNameController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Last Name',
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(8.0),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(8.0),
                borderSide: new BorderSide(),
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter valid Name';
              }
              return null;
            },
          ),
          SizedBox(
            height: 16.0,
          ),
          TextFormField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Contact',
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(8.0),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(8.0),
                borderSide: new BorderSide(),
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter valid phone';
              }
              return null;
            },
          ),
          SizedBox(
            height: 16.0,
          ),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(8.0),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(8.0),
                borderSide: new BorderSide(),
              ),
            ),
            validator: (value) {
              if (!isEmail(value)) {
                return 'Please enter valid email';
              }
              return null;
            },
          ),
          SizedBox(
            height: 16.0,
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Password',
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(8.0),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(8.0),
                borderSide: new BorderSide(),
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            width: double.maxFinite,
            child: FlatButton(
                color: Colors.green[800],
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    loginBloc.add(ProcessRegistration(
                        _firstNameController.text,
                        _lastNameController.text,
                        _emailController.text,
                        _passwordController.text,
                        "92",
                        _phoneNumberController.text));
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "Register",
                  style: TextStyle(color: Colors.white),
                )),
          ),
          SizedBox(
            height: 16.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account?"),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    _isDialogShowing = true;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }
}
