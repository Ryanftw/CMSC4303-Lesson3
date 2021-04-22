import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/likes.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:Assignment3/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'addcomment_screen.dart';
import 'myview/myimage.dart';
import 'viewcomments_screen.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  _Controller con;
  User user;
  List<PhotoMemo> photoMemoList;
  bool flag = false;
  PhotoMemo tempPhotoMemo;
  List<Likes> userLikes;

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
    userLikes ??= args[Constant.ARG_LIKES];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    return Scaffold(
      appBar: AppBar(
        title: Text("Shared With Screen"),
      ),
      body: photoMemoList.length == 0
          ? Text(
              "No PhotoMemos shared with me",
              style: Theme.of(context).textTheme.headline5,
            )
          : ListView.builder(
              itemCount: photoMemoList.length,
              itemBuilder: (context, index) => Stack(
                children: [
                  Card(
                    elevation: 7.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: MyImage.network(
                                url: photoMemoList[index].photoURL,
                                context: context,
                              ),
                            ),
                            onTap: () => con.thumbsUp(index),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                "Title: ${photoMemoList[index].title}",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: RaisedButton(
                                onPressed: () => con.addComment(index),
                                child: Text("Add Comment"),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                "Memo: ${photoMemoList[index].memo}",
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: RaisedButton(
                                onPressed: () => con.viewComments(index),
                                child: Text("View Comments"),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Created By: ${photoMemoList[index].createdBy}",
                        ),
                        Text(
                          "Updated At: ${photoMemoList[index].timestamp}",
                        ),
                        Text(
                          "Shared With: ${photoMemoList[index].sharedWith}",
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 1.0,
                    left: 1.0,
                    child: IconButton(
                      icon: Icon(
                        photoMemoList[index].likedBy.isEmpty
                            ? Icons.thumb_up_outlined
                            : (photoMemoList[index].likedBy.contains(
                                    user.email)) // == photoMemoList[index].photoURL
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () => con.thumbsUp(index),
                      iconSize: 28,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Controller {
  _SharedWithState state;
  _Controller(this.state);

  void addComment(int index) {
    Navigator.pushNamed(state.context, AddCommentScreen.routeName, arguments: {
      Constant.ARG_USER: state.user,
      Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
    });
  }

  void viewComments(int index) async {
    try {
      List<Comment> comments = await FirebaseController.getCommentList(
          docId: state.photoMemoList[index].photoURL);
      Navigator.pushNamed(state.context, ViewCommentsScreen.routeName, arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
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

  void thumbsUp(int index) async {
    PhotoMemo tempMemo = PhotoMemo.clone(state.photoMemoList[index]);
    List<dynamic> tempList = tempMemo.likedBy;
    List<Likes> tempLikes = new List<Likes>(); // = state.userLikes;
    if (state.userLikes.length > 0) {
      for (var like in state.userLikes) {
        Likes templike = Likes.clone(like);
        tempLikes.add(templike);
      }
    }
    Map<String, dynamic> updateInfo = {};
    int localIndex;
    try {
      if (tempMemo.likedBy.contains(state.user.email)) {
        localIndex =
            tempLikes.indexWhere((element) => element.likeDocId == tempMemo.photoURL);
        await FirebaseController.deleteLike(tempLikes.elementAt(localIndex).docId);
        state.userLikes.remove(localIndex);
        tempLikes.removeAt(localIndex);
        tempList.removeWhere((element) => element == state.user.email);
        updateInfo[PhotoMemo.LIKED_BY] = tempList;
        tempMemo.likes = tempList.length;
        updateInfo[PhotoMemo.LIKES] = tempMemo.likes;
        tempMemo.likedBy.clear();
        tempList.forEach((element) {
          tempMemo.likedBy.add(element);
        });
        await FirebaseController.updatePhotoMemo(tempMemo.docID, updateInfo);
        state.photoMemoList[index].assign(tempMemo);
        state.render(() {});
      } else {
        Likes like = new Likes();
        like.likeDocId = tempMemo.photoURL;
        like.likedBy = state.user.email;
        like.likeOn = tempMemo.createdBy;
        like.userProfilePic = state.user.photoURL;
        like.timestamp = DateTime.now();
        var docId = await FirebaseController.addNewLike(like);
        like.docId = docId;
        Map<String, dynamic> updateDocId = {};
        updateDocId[Likes.DOC_ID] = docId;
        await FirebaseController.updateLike(docId, updateDocId);
        state.userLikes.insert(0, like);
        tempList.add(state.user.email);
        updateInfo[PhotoMemo.LIKED_BY] = tempList;
        tempMemo.likes = tempList.length;
        updateInfo[PhotoMemo.LIKES] = tempMemo.likes;
        tempMemo.likedBy = tempList;
        await FirebaseController.updatePhotoMemo(tempMemo.docID, updateInfo);
        state.photoMemoList[index].assign(tempMemo);
        state.render(() {});
      }
    } catch (e) {
      MyDialog.info(
          context: state.context,
          title: "Asyncronous Page Update Error",
          content: e.toString());
    }
  }
}
