import 'dart:io';

import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:Assignment3/model/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseController {
  static Future<User> signIn({@required String email, @required String password}) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  static Future<void> createAccount(
      {@required String email, @required String password}) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await FirebaseFirestore.instance
        .collection(Constant.PROFILE_COLLECTION)
        .add(new Profile(email: email).serialize());
    //     .then((result) {
    //   return result.user.updateProfile(displayName: name);
    // });
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<Map<String, String>> uploadPhotoFile({
    @required File photo,
    String filename,
    @required String uid,
    @required Function listener,
  }) async {
    filename ??= '${Constant.PHOTOIMAGE_FOLDER}/$uid/${DateTime.now()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      double progress = event.bytesTransferred / event.totalBytes;
      if (event.bytesTransferred == event.totalBytes) progress = null;
      listener(progress);
    });
    await task;
    String downloadURL = await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return <String, String>{
      Constant.ARG_DOWNLOADURL: downloadURL,
      Constant.ARG_FILENAME: filename,
    };
  }

  static Future<String> updateProfile(String email, Map<String, dynamic> pInfo) async {
    FirebaseFirestore.instance
        .collection(Constant.PROFILE_COLLECTION)
        .where(Profile.EMAIL, isEqualTo: email)
        .get();
    // await FirebaseFirestore.instance.collection(Constant.PROFILE_COLLECTION).doc(p)
  }

  static Future<String> addPhotoMemo(PhotoMemo photoMemo) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .add(photoMemo.serialize());
    return ref.id;
  }

  static Future<String> addComment(Comment comment) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.COMMENT_COLLECTION)
        .add(comment.serialize());
    return ref.id;
  }

  static Future<List<PhotoMemo>> getPhotoMemoList({@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();
    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      // LOOK A THIS. FOR EACH --> IF THE COMMENT.COMMENTID == PHOTOMEMO.PHOTOURL && COMMENT.TIMESTAMP > PHOTOMEMO.LASTVIEWED -> KEEP THE PHOTOMEMO
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<Comment>> getCommentList({@required String docId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.COMMENT_COLLECTION)
        .where(Comment.COMMENT_DOC_ID, isEqualTo: docId)
        .orderBy(Comment.TIMESTAMP, descending: true)
        .get();
    var result = <Comment>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Comment.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<dynamic>> getImageLabels({@required File photoFile}) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(photoFile);
    final ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
    final List<ImageLabel> cloudLabels = await cloudLabeler.processImage(visionImage);
    List<dynamic> labels = <dynamic>[];
    for (ImageLabel label in cloudLabels) {
      if (label.confidence >= Constant.MIN_ML_CONFIDENCE) {
        labels.add(label.text.toLowerCase());
      }
    }
    return labels;
  }

  static Future<void> updatePhotoMemo(
      String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docId) // docID of the individual photomemo
        .update(updateInfo); // only the info that has been changed will be updated
  }

  static Future<String> addNewProfile(Profile profile) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PROFILE_COLLECTION)
        .add(profile.serialize());
    return ref.id;
  }

  // static Future<bool> validateUsername(String name) async {
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection(Constant.PROFILE_COLLECTION)
  //       .where(Profile.DISPLAY_NAME, isEqualTo: name)
  //       .get();
  //   if (querySnapshot.size > 0)
  //     return false;
  //   else
  //     return true;
  // }

  static Future<void> updateLastViewed(
      String docId, Map<String, dynamic> updateLastViewed) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docId)
        .update(updateLastViewed);
  }

  static Future<List<PhotoMemo>> getPhotoMemoSharedWithMe(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();
    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<void> deletePhotoMemo(PhotoMemo p) async {
    await deletePhotoMemoComments(docId: p.photoURL);

    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(p.docID)
        .delete();
    await FirebaseStorage.instance.ref().child(p.photoFilename).delete();
  }

  static Future<void> deletePhotoMemoComments({@required String docId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.COMMENT_COLLECTION)
        .where(Comment.COMMENT_DOC_ID, isEqualTo: docId)
        .get();
    querySnapshot.docs.forEach((doc) async {
      print('${doc.id}');
      await FirebaseFirestore.instance
          .collection(Constant.COMMENT_COLLECTION)
          .doc(doc.id)
          .delete();
    });
  }

  static Future<void> deletePhotoComment({@required String docId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.COMMENT_COLLECTION)
        .where(Comment.COMMENT_BY, isEqualTo: docId)
        .get();
    querySnapshot.docs.forEach((doc) async {
      print('${doc.id}');
      await FirebaseFirestore.instance
          .collection(Constant.COMMENT_COLLECTION)
          .doc(doc.id)
          .delete();
    });
  }

  static Future<List<PhotoMemo>> searchImage({
    @required String createdBy,
    @required List<String> searchLabels,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: createdBy)
        .where(PhotoMemo.IMAGE_LABELS, arrayContainsAny: searchLabels)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();
    var results = <PhotoMemo>[];
    querySnapshot.docs
        .forEach((doc) => results.add(PhotoMemo.deserialize(doc.data(), doc.id)));
    return results;
  }
}
