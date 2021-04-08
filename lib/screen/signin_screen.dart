import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/likes.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:Assignment3/model/profile.dart';
import 'package:Assignment3/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'signup_screen.dart';
import 'userhome_screen.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 15.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Text(
                    "PhotoMemo",
                    style: TextStyle(fontFamily: 'Pacifico', fontSize: 40.0),
                  ),
                ),
                Center(
                  child: Text(
                    "Sign in, please!",
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                    ),
                  ),
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
                RaisedButton(
                  onPressed: con.signIn,
                  child: Text('Sign In', style: Theme.of(context).textTheme.button),
                ),
                SizedBox(height: 15.0),
                RaisedButton(
                  onPressed: con.signUp,
                  child: Text(
                    'Create a new account',
                    style: Theme.of(context).textTheme.button,
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

class _Controller {
  _SignInState state;
  _Controller(this.state);
  String email;
  String userName;
  String password;

  String validateEmail(String value) {
    if (value.contains('@') && value.contains('.'))
      return null;
    else
      return 'Invalid Login';
  }

  String validatePassword(String value) {
    if (value.length < 6)
      return "Too short";
    else
      return null;
  }

  void saveEmail(String value) {
    email = value;
  }

  void savePassword(String value) {
    password = value;
  }

  void signIn() async {
    if (!state.formKey.currentState.validate()) return;
    try {
      state.formKey.currentState.save();
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: "Sign-in Error",
        content: e.toString(),
      );
      return;
    }

    User user;

    MyDialog.circularProgressStart(state.context);

    try {
      user = await FirebaseController.signIn(email: email, password: password);
      print('====== ${user.email}');
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Sign In Error',
        content: e.toString(),
      );
      return;
    }
    List<PhotoMemo> photoMemoList;
    List<List<Comment>> commentsList = new List<List<Comment>>();
    try {
      photoMemoList = await FirebaseController.getPhotoMemoList(email: user.email);

      for (var memo in photoMemoList) {
        List<Comment> comments =
            await FirebaseController.getCommentList(docId: memo.photoURL);
        if (comments.length > 0) commentsList.add(comments);
      }

      if (commentsList != null) {
        for (var cList in commentsList) {
          for (var comment in cList) {
            for (var photo in photoMemoList) {
              if (comment.commentDocId == photo.photoURL &&
                  comment.timestamp.isAfter(photo.lastViewed)) {
                photo.notification = true;
              }
            }
          }
        }
      }

      Profile profile = new Profile();
      List<Profile> myProfile = await FirebaseController.getUserProfile(user.email);
      print('${myProfile.length}');
      if (myProfile.length > 0) {
        profile.assign(myProfile.elementAt(0));
      }

      List<Likes> likes = await FirebaseController.getUserLikes(email: user.email);
      if (likes.isNotEmpty) {
        for (var like in likes) {
          for (var photo in photoMemoList) {
            if (photo.likesLastViewed != null &&
                like.likeDocId == photo.photoURL &&
                like.timestamp.isAfter(photo.likesLastViewed)) {
              photo.likeNotification = true;
            }
          }
        }
      }
      MyDialog.circularProgressStop(state.context);
      Navigator.pushNamed(state.context, UserHomeScreen.routeName, arguments: {
        Constant.ARG_USER: user,
        Constant.ARG_PHOTOMEMOLIST: photoMemoList,
        Constant.ARG_ONE_PROFILE: profile,
      });
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Firestore getPhotoMemoList error',
        content: '$e',
      );
    }
  }

  void signUp() {
    Navigator.pushNamed(state.context, SignUpScreen.routeName);
  }
}
