import 'dart:io';

import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/likes.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:Assignment3/model/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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

  static Future<void> updateProfile(String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PROFILE_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<void> updateLike(String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.LIKES_COLLECTION)
        .doc(docId)
        .update(updateInfo);
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

  static Future<List<Likes>> getUserLikes({@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.LIKES_COLLECTION)
        .where(Likes.LIKE_ON, isEqualTo: email)
        .orderBy(Likes.TIMESTAMP, descending: true)
        .get();
    var result = <Likes>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Likes.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<Likes>> getOnePhotoLikes(String memoURL) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.LIKES_COLLECTION)
        .where(Likes.LIKE_DOC_ID, isEqualTo: memoURL)
        .get();
    var result = <Likes>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Likes.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<Likes>> getUserSharedLikes({@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.LIKES_COLLECTION)
        .where(Likes.LIKED_BY, isEqualTo: email)
        .orderBy(Likes.TIMESTAMP, descending: true)
        .get();
    var result = <Likes>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Likes.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<dynamic>> recogniseText(File imageFile) async {
    final visionImage = FirebaseVisionImage.fromFile(imageFile);
    final textRecognizer = FirebaseVision.instance.textRecognizer();
    final visionText = await textRecognizer.processImage(visionImage);
    await textRecognizer.close();
    List<dynamic> labels = <dynamic>[]; 
    labels = extractText(visionText);
    if(labels.isEmpty) {labels.addAll("No text found in the image".split(' '));}
    return labels;
    
  }

  static extractText(VisionText visionText) {
    List<dynamic> text = new List<dynamic>(); 
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          text.add(word.text.toLowerCase()); 
        }
        text.add("\n");
      }
    }
    return text; 
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

  static Future<List<Profile>> getUserProfile(String userEmail) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PROFILE_COLLECTION)
        .where(Profile.EMAIL, isEqualTo: userEmail)
        .get();
    var result = <Profile>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Profile.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<String> addNewLike(Likes like) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.LIKES_COLLECTION)
        .add(like.serialize());
    return ref.id;
  }

  static Future<String> addNewProfile(Profile profile) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PROFILE_COLLECTION)
        .add(profile.serialize());
    return ref.id;
  }

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

  static Future<void> deleteProfilePicture(String fileName) async {
    await FirebaseStorage.instance.ref().child(fileName).delete();
  }

  static Future<void> deletePhotoMemo(PhotoMemo p) async {
    await deletePhotoMemoComments(docId: p.photoURL);

    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(p.docID)
        .delete();
    await FirebaseStorage.instance.ref().child(p.photoFilename).delete();
  }

  static Future<void> deleteLike(String docId) async {
    await FirebaseFirestore.instance
        .collection(Constant.LIKES_COLLECTION)
        .doc(docId)
        .delete();
  }

  // static Future<void> deletePhotoLike(String docId) async {
  //   await FirebaseFirestore.instance
  //       .collection(Constant.LIKES_COLLECTION)
  //       .doc(docId)
  //       .delete();
  // }

  static Future<void> deletePhotoLikes(String docId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.LIKES_COLLECTION)
        .where(Likes.LIKE_DOC_ID, isEqualTo: docId)
        .get();
    querySnapshot.docs.forEach((doc) async {
      await FirebaseFirestore.instance
          .collection(Constant.LIKES_COLLECTION)
          .doc(doc.id)
          .delete();
    });
  }

  static Future<void> deletePhotoMemoComments({@required String docId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.COMMENT_COLLECTION)
        .where(Comment.COMMENT_DOC_ID, isEqualTo: docId)
        .get();
    querySnapshot.docs.forEach((doc) async {
      await FirebaseFirestore.instance
          .collection(Constant.COMMENT_COLLECTION)
          .doc(doc.id)
          .delete();
    });
  }

  static Future<void> updateComment(String docId, Map<String, dynamic> update) async {
    await FirebaseFirestore.instance
        .collection(Constant.COMMENT_COLLECTION)
        .doc(docId)
        .update(update);
  }

  static Future<void> deletePhotoComment({@required String docId}) async {
    await FirebaseFirestore.instance
        .collection(Constant.COMMENT_COLLECTION)
        .doc(docId)
        .delete();
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

  static Future<List<Profile>> searchProfile(List<String>searchLabels) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Constant.PROFILE_COLLECTION).where(Profile.DISPLAY_NAME, whereIn: searchLabels).get();
    var results = <Profile>[]; 
    querySnapshot.docs
        .forEach((doc) => results.add(Profile.deserialize(doc.data(), doc.id)));
    return results; 
  }
}
