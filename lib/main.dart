import 'package:Assignment3/screen/addphotomemo_screen.dart';
import 'package:Assignment3/screen/detailedview_screen.dart';
import 'package:Assignment3/screen/userhome_screen.dart';
import 'package:Assignment3/screen/viewlikes_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'model/constant.dart';
import 'screen/addcomment_screen.dart';
import 'screen/profilesettings_screen.dart';
import 'screen/sharedwith_screen.dart';
import 'screen/signin_screen.dart';
import 'screen/signup_screen.dart';
import 'screen/viewcomments_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PhotoMemoApp());
}

class PhotoMemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: Constant.DEV,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blue,
        ),
        initialRoute: SignInScreen.routeName,
        routes: {
          SignInScreen.routeName: (context) => SignInScreen(),
          UserHomeScreen.routeName: (context) => UserHomeScreen(),
          AddPhotoMemoScreen.routeName: (context) => AddPhotoMemoScreen(),
          DetailedViewScreen.routeName: (context) => DetailedViewScreen(),
          SignUpScreen.routeName: (context) => SignUpScreen(),
          SharedWithScreen.routeName: (context) => SharedWithScreen(),
          AddCommentScreen.routeName: (context) => AddCommentScreen(),
          ViewCommentsScreen.routeName: (context) => ViewCommentsScreen(),
          ProfileSettingsScreen.routeName: (context) => ProfileSettingsScreen(),
          ViewLikesScreen.routeName: (context) => ViewLikesScreen(),
        });
  }
}
