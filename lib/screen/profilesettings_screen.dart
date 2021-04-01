import 'dart:io';

import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'myview/mydialog.dart';
import 'myview/myimage.dart';

class ProfileSettingsScreen extends StatefulWidget {
  static const routeName = '/ProfileSettingsScreen';
  @override
  State<StatefulWidget> createState() {
    return _ProfileSettingsState();
  }
}

class _ProfileSettingsState extends State<ProfileSettingsScreen> {
  _Controller con;
  User user;
  String photourl;

  bool editMode = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String progressMessage;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Screen"),
        actions: [
          editMode
              ? IconButton(icon: Icon(Icons.check), onPressed: con.update)
              : IconButton(icon: Icon((Icons.edit)), onPressed: con.edit),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: user.photoURL == null
                        ? con.photoFile == null
                            ? Icon(
                                Icons.supervised_user_circle,
                                size: 300,
                              )
                            : Image.file(
                                con.photoFile,
                                fit: BoxFit.fill,
                              )
                        : MyImage.network(
                            url: user.photoURL,
                            context: context,
                          ),
                  ),
                  editMode
                      ? Positioned(
                          right: 0.0,
                          bottom: 0.0,
                          child: Container(
                            color: Colors.blue[100],
                            child: PopupMenuButton<String>(
                              onSelected: con.getPhoto,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: Constant.SRC_CAMERA,
                                  child: Row(
                                    children: [
                                      Icon(Icons.photo_camera),
                                      Text(Constant.SRC_CAMERA),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: Constant.SRC_GALLERY,
                                  child: Row(
                                    children: [
                                      Icon(Icons.photo_library),
                                      Text(Constant.SRC_GALLERY),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 1.0,
                        ),
                ],
              ),
              progressMessage == null
                  ? SizedBox(
                      height: 1.0,
                    )
                  : Text(
                      progressMessage,
                      style: Theme.of(context).textTheme.headline6,
                    ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(
                  hintText: "Name",
                ),
                // initialValue: onePhotoMemoTemp.memo,
                autocorrect: false,
                keyboardType: TextInputType.name,
                maxLines: 1,
                validator: con.validateName,
                onSaved: con.saveName,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(
                  hintText: "Age",
                ),
                initialValue: "",
                // autocorrect: true,
                // keyboardType: TextInputType.values,
                maxLines: 1,
                validator: con.validateAge,
                onSaved: con.saveAge,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(
                  hintText: "Display Name",
                ),
                initialValue: user.displayName,
                autocorrect: false,
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                validator: con.validateDisplayName,
                onSaved: con.saveDisplayName,
              ),
              SizedBox(
                height: 5.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _ProfileSettingsState state;
  _Controller(this.state);
  File photoFile;
  String name;
  String age;
  String userName;

  String validateName(String value) {
    if (value.length > 1) return null;
    return "Too short";
  }

  void saveName(String value) {
    name = value;
  }

  String validateAge(String value) {
    try {
      int age = int.parse(value);
      if (age >= 5)
        return null;
      else
        return 'Min age is 5';
    } catch (e) {
      return 'Not valid age';
    }
  }

  void saveAge(String value) {
    age = value;
  }

  String validateDisplayName(String value) {
    if (value.length > 2) return null;
    return "Too Short";
  }

  void saveDisplayName(String value) {
    userName = value;
  }

  void update() async {
    if (!state.formKey.currentState.validate()) return;
    if (photoFile == null) return;
    state.formKey.currentState.save();

    MyDialog.circularProgressStart(state.context);
    try {
      Map photoInfo = await FirebaseController.uploadPhotoFile(
        photo: photoFile,
        uid: state.user.uid,
        listener: (double progress) {
          state.render(() {
            if (progress == null)
              state.progressMessage = null;
            else {
              progress *= 100;
              state.progressMessage = 'Uploading: ' + progress.toStringAsFixed(1) + ' %';
            }
          });
        },
      );
      String photoFileName = photoInfo[Constant.ARG_FILENAME];
      String photoURL = photoInfo[Constant.ARG_DOWNLOADURL];
      state.user.updateProfile(
          displayName: userName, photoURL: photoInfo[Constant.ARG_DOWNLOADURL]);
      // await FirebaseController.updateProfile(state.user.email, photoInfo);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
      print(state.user.photoURL);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Update Profile Error',
        content: '$e',
      );
    }
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void getPhoto(String src) async {
    try {
      PickedFile _photoFile;
      if (src == Constant.SRC_CAMERA) {
        _photoFile = await ImagePicker().getImage(source: ImageSource.camera);
      } else {
        _photoFile = await ImagePicker().getImage(source: ImageSource.gallery);
      }
      if (_photoFile == null) return; // selection canceled
      state.render(() => photoFile = File(_photoFile.path));
    } catch (e) {
      MyDialog.info(context: state.context, title: 'getPhoto error', content: '$e');
    }
  }
}