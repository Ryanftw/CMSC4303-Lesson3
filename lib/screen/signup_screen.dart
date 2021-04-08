import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/profile.dart';
import 'package:flutter/material.dart';

import 'myview/mydialog.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signUpScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Profile profile = new Profile();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create an account",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          left: 15.0,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Create an account", style: Theme.of(context).textTheme.headline5),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Username',
                  ),
                  autocorrect: false,
                  validator: con.validateUsername,
                  onSaved: con.saveUsername,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                  ),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Password confirm',
                  ),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePasswordConfirm,
                ),
                con.passwordErrorMessage == null
                    ? SizedBox(
                        height: 1.0,
                      )
                    : Text(
                        con.passwordErrorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                        ),
                      ),
                RaisedButton(
                  onPressed: con.createAccount,
                  child: Text(
                    "Create",
                    style: Theme.of(context).textTheme.button,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignUpState state;
  _Controller(this.state);
  String email;
  String password;
  String passwordConfirm;
  String passwordErrorMessage;

  void createAccount() async {
    if (!state.formKey.currentState.validate()) return;
    if (password != passwordConfirm) {
      state.render(() => passwordErrorMessage = "Password do not match");
      return;
    }
    state.render(() => passwordErrorMessage = null);
    state.profile.age = "";
    state.profile.name = "";
    state.profile.docId = "";
    state.profile.profileFilename = "";
    state.profile.age = "";
    state.profile.url = "";

    state.formKey.currentState.save();

    MyDialog.circularProgressStart(state.context);

    try {
      await FirebaseController.createAccount(email: email, password: password);
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: "Cannot create",
        content: '$e',
      );
      return;
    }
    try {
      var docId = await FirebaseController.addNewProfile(state.profile);
      state.profile.docId = docId;
      Map<String, dynamic> updateProfileDocId = {};
      updateProfileDocId[Profile.DOC_ID] = docId;
      await FirebaseController.updateProfile(docId, updateProfileDocId);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
      MyDialog.info(
        context: state.context,
        title: "Account created!",
        content: "Please Sign In to use the app",
      );
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: "Cannot create Profile",
        content: '$e',
      );
    }
  }

  String validateEmail(String value) {
    if (value.contains('@') && value.contains('.'))
      return null;
    else
      return 'invalid email';
  }

  String validateUsername(String value) {
    if (value.length > 3)
      return null;
    else
      return "Username length minimum is 4";
  }

  void saveUsername(String value) {
    state.profile.displayName = value;
  }

  void saveEmail(String value) {
    email = value;
    state.profile.email = value;
  }

  String validatePassword(String value) {
    if (value.length < 6)
      return "Too short";
    else
      return null;
  }

  void savePassword(String value) {
    password = value;
  }

  void savePasswordConfirm(String value) {
    passwordConfirm = value;
  }
}
