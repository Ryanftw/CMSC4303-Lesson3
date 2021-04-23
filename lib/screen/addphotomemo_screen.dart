import 'dart:io';

import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'myview/mydialog.dart';

class AddPhotoMemoScreen extends StatefulWidget {
  static const routeName = "/addPhotoMemoScreen";
  @override
  State<StatefulWidget> createState() {
    return _AddPhotoMemoState();
  }
}

class _AddPhotoMemoState extends State<AddPhotoMemoScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File photo;
  bool public; 
  User user;

  MLAlgorithm labeler; 
  List<PhotoMemo> photoMemoList;
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
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    return Scaffold(
      appBar: AppBar(
        title: Text("Add PhotoMemo"),
        actions: [
          IconButton(icon: Icon(Icons.check), onPressed: con.save),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: photo == null
                            ? Icon(
                                Icons.photo_library,
                                size: 300,
                              )
                            : Image.file(
                                photo,
                                fit: BoxFit.scaleDown,
                              ),
                      ),
                      Positioned(
                        right: 0.0,
                        bottom: 0.0,
                        child: Container(
                          color: Colors.blue[200],
                          child: PopupMenuButton<String>(
                            onSelected: con.getPhoto,
                            itemBuilder: (context) => <PopupMenuEntry<String>>[
                              // type of each element which is menu item
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
                                    Icon(Icons.photo_album),
                                    Text(Constant.SRC_GALLERY),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Title',
                ),
                autocorrect: true,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Memo',
                ),
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              RadioListTile(
                  title: Text("Public"),
                  dense: true,
                  value: true,
                  groupValue: public,
                  onChanged: (value) {render(() => public = value);} 
                ),
              RadioListTile(
                  title: Text("Private"),
                  dense: true,
                  value: false,
                  groupValue: public,
                  onChanged: (value) {render(() => public = value);} 
                ),
              public == false 
              ? TextFormField(
                  decoration: InputDecoration(
                    hintText: 'SharedWith (comma separated email list)',
                  ),
                  autocorrect: false, // set to false because it is email
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 2,
                  validator: PhotoMemo.validateSharedWith,
                  onSaved: con.saveSharedWith,
                )
              : SizedBox(height: 1.0,),
              Column(children: [
                RadioListTile(
                  title: Text(MLAlgorithm.MLLabels.toString().split('.')[1]),
                  dense: true,
                  value: MLAlgorithm.MLLabels,
                  groupValue: labeler,
                  onChanged: (value) {render(() => labeler = value);} 
                ),
                RadioListTile(
                  title: Text(MLAlgorithm.MLText.toString().split('.')[1]),
                  dense: true,
                  value: MLAlgorithm.MLText,
                  groupValue: labeler,
                  onChanged: (value) {render(() => labeler = value);} 
                ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _AddPhotoMemoState state;
  _Controller(this.state);
  PhotoMemo tempMemo = PhotoMemo();

  void save() async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();

    if(state.labeler == null) return MyDialog.info(context: state.context, title: "No Labeler Chosen", content: "You must select an image Labeler!!");

    MyDialog.circularProgressStart(state.context);

    try {
      Map photoInfo = await FirebaseController.uploadPhotoFile(
        photo: state.photo,
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

      // image labels by Machine learning
      List<dynamic> imageLabels;
      if(state.labeler == MLAlgorithm.MLLabels) {
        state.render(() => state.progressMessage = 'ML Image Labeler Started!');
        imageLabels =
          await FirebaseController.getImageLabels(photoFile: state.photo);
      } else {
        state.render(() => state.progressMessage = 'ML Text Labeler Started!');
        imageLabels =
          await FirebaseController.recogniseText(state.photo);
      }
      state.render(() => state.progressMessage = null);

      if(state.public == true) 
        tempMemo.public = true; 
      else
        tempMemo.public = false;
      tempMemo.photoFilename = photoInfo[Constant.ARG_FILENAME];
      tempMemo.photoURL = photoInfo[Constant.ARG_DOWNLOADURL];
      tempMemo.timestamp = DateTime.now();
      tempMemo.labeler = state.labeler.toString(); 
      tempMemo.createdBy = state.user.email;
      tempMemo.imageLabels = imageLabels;
      tempMemo.likes = 0;
      String docId = await FirebaseController.addPhotoMemo(tempMemo);
      tempMemo.docID = docId;
      state.photoMemoList.insert(0, tempMemo);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context); // return to user home screen.
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Save PhotoMemo error',
        content: '$e',
      );
    }
  }

  void getPhoto(String src) async {
    // defined above as Popupmenubutton<String> --> This is why it receives a string
    try {
      PickedFile _imageFile;
      var _picker = ImagePicker();
      if (src == Constant.SRC_CAMERA) {
        _imageFile = await _picker.getImage(source: ImageSource.camera);
      } else {
        _imageFile = await _picker.getImage(source: ImageSource.gallery);
      }
      if (_imageFile == null) return; //Selection canceled
      state.render(() => state.photo = File(_imageFile.path));
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: "Failed to get picture",
        content: '$e',
      );
    }
  }

  void saveTitle(String value) {
    tempMemo.title = value;
  }

  void saveMemo(String value) {
    tempMemo.memo = value;
  }

  void saveSharedWith(String value) {
    if(state.public == false) {
      if (value.trim().length != 0) {
        tempMemo.sharedWith = value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
      }
    }
  }
}
