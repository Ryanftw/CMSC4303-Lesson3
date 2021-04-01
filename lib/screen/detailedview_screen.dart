// import 'dart:html';
import 'dart:io';

import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/Material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'viewcomments_screen.dart';

import 'myview/mydialog.dart';
import 'myview/myimage.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';
  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  _Controller con;
  User user;
  PhotoMemo onePhotoMemoOriginal;
  PhotoMemo onePhotoMemoTemp;
  bool editMode = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String progressMessage;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  // @override
  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    onePhotoMemoOriginal ??= args[Constant.ARG_ONE_PHOTOMEMO];
    onePhotoMemoTemp ??= PhotoMemo.clone(onePhotoMemoOriginal);
    return Scaffold(
      appBar: AppBar(
        title: Text("Detailed View"),
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
                    child: con.photoFile == null
                        ? MyImage.network(
                            url: onePhotoMemoTemp.photoURL,
                            context: context,
                          )
                        : Image.file(
                            con.photoFile,
                            fit: BoxFit.fill,
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
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      enabled: editMode,
                      style: Theme.of(context).textTheme.headline6,
                      decoration: InputDecoration(
                        hintText: "Enter title",
                      ),
                      initialValue: onePhotoMemoTemp.title,
                      autocorrect: true,
                      validator: PhotoMemo.validateTitle,
                      onSaved: con.saveTitle,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: RaisedButton(
                      onPressed: con.viewComments,
                      child: Text("View Comments"),
                    ),
                  ),
                ],
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(
                  hintText: "Enter memo",
                ),
                initialValue: onePhotoMemoTemp.memo,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(
                  hintText: "Shared With",
                ),
                initialValue: onePhotoMemoTemp.sharedWith.join(','),
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),
              SizedBox(
                height: 5.0,
              ),
              Constant.DEV
                  ? Text(
                      'Image Labels generated by ML',
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  : SizedBox(
                      height: 1.0,
                    ),
              Constant.DEV
                  ? Text(
                      onePhotoMemoTemp.imageLabels.join(' | '),
                    )
                  : SizedBox(
                      height: 1.0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _DetailedViewState state;
  _Controller(this.state);
  File photoFile; // camera or gallery

  void update() async {
    if (!state.formKey.currentState.validate()) return;

    state.formKey.currentState.save();
    // state.render(() => state.editMode = false);

    try {
      bool commentsDeleted = false;
      MyDialog.circularProgressStart(state.context);
      Map<String, dynamic> updateInfo =
          {}; // store CHANGES - like title and memo - from each docID that has changes.
      if (photoFile != null) {
        Map photoInfo = await FirebaseController.uploadPhotoFile(
            filename: state.onePhotoMemoTemp.photoFilename,
            photo: photoFile,
            uid: state.user.uid,
            listener: (double message) {
              state.render(() {
                if (message == null)
                  state.progressMessage = null;
                else {
                  message *= 100;
                  state.progressMessage =
                      "Uploading: " + message.toStringAsFixed(1) + " %";
                }
              });
            });
        commentsDeleted = true;
        print('${state.onePhotoMemoOriginal.photoURL}');
        await FirebaseController.deletePhotoMemoComments(
            docId: state.onePhotoMemoOriginal.photoURL);

        state.onePhotoMemoTemp.photoURL = photoInfo[Constant.ARG_DOWNLOADURL];
        state.render(() => state.progressMessage = 'ML image labeler started');
        List<dynamic> labels =
            await FirebaseController.getImageLabels(photoFile: photoFile);
        state.onePhotoMemoTemp.imageLabels = labels;

        updateInfo[PhotoMemo.PHOTO_URL] = photoInfo[Constant.ARG_DOWNLOADURL];
        updateInfo[PhotoMemo.IMAGE_LABELS] = labels;
      }

      // Determine the updated fields other than photo related ones.
      if (state.onePhotoMemoOriginal.title != state.onePhotoMemoTemp.title)
        updateInfo[PhotoMemo.TITLE] = state.onePhotoMemoTemp.title;
      if (state.onePhotoMemoOriginal.memo != state.onePhotoMemoTemp.memo)
        updateInfo[PhotoMemo.MEMO] = state.onePhotoMemoTemp.memo;
      if (!listEquals(
          state.onePhotoMemoOriginal.sharedWith, state.onePhotoMemoTemp.sharedWith)) {
        updateInfo[PhotoMemo.SHARED_WITH] = state.onePhotoMemoTemp.sharedWith;
        if (!commentsDeleted) {
          List<Comment> comments = await FirebaseController.getCommentList(
              docId: state.onePhotoMemoOriginal.photoURL);
          for (Comment comment in comments) {
            if (!state.onePhotoMemoTemp.sharedWith.contains(comment.commentBy)) {
              await FirebaseController.deletePhotoComment(docId: comment.commentBy);
            }
          }
        }
      }

      updateInfo[PhotoMemo.TIMESTAMP] = DateTime.now();
      await FirebaseController.updatePhotoMemo(state.onePhotoMemoTemp.docID, updateInfo);

      state.onePhotoMemoOriginal.assign(state.onePhotoMemoTemp);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context, title: 'Update photoMemo error', content: '$e');
    }
  }

  void viewComments() async {
    try {
      state.onePhotoMemoOriginal.notification = false;
      Map<String, dynamic> updateLastViewed = {};
      state.onePhotoMemoOriginal.lastViewed = DateTime.now();
      updateLastViewed[PhotoMemo.LAST_VIEWED] = state.onePhotoMemoOriginal.lastViewed;
      await FirebaseController.updateLastViewed(
          state.onePhotoMemoOriginal.docID, updateLastViewed);
      List<Comment> comments = await FirebaseController.getCommentList(
          docId: state.onePhotoMemoOriginal.photoURL);
      Navigator.pushNamed(state.context, ViewCommentsScreen.routeName, arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTOMEMO: state.onePhotoMemoOriginal,
        Constant.ARG_COMMENTS: comments,
      });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: "Firebase Comments Error",
        content: "$e",
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

  // void getPhoto(String src) async {
  //   // defined above as Popupmenubutton<String> --> This is why it receives a string
  //   try {
  //     PickedFile _imageFile;
  //     var _picker = ImagePicker();
  //     if (src == Constant.SRC_CAMERA) {
  //       _imageFile = await _picker.getImage(source: ImageSource.camera);
  //     } else {
  //       _imageFile = await _picker.getImage(source: ImageSource.gallery);
  //     }
  //     if (_imageFile == null) return; //Selection canceled
  //     state.render(() => state.photo = File(_imageFile.path));
  //   } catch (e) {
  //     MyDialog.info(
  //       context: state.context,
  //       title: "Failed to get picture",
  //       content: '$e',
  //     );
  //   }

  void saveTitle(String value) {
    state.onePhotoMemoTemp.title = value;
  }

  void saveMemo(String value) {
    state.onePhotoMemoTemp.memo = value;
  }

  void saveSharedWith(String value) {
    if (value.trim().length != 0) {
      state.onePhotoMemoTemp.sharedWith =
          value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    }
  }
}
