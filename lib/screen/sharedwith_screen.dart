import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
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
  // List<Comment> commentList;

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
    // commentList ??= args[Constant.ARG_COMMENTS];
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
          // : Padding(
          //     padding: EdgeInsets.all(8.0),
          //     child: GridView.builder(
          //       gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          //         maxCrossAxisExtent: 200,
          //         childAspectRatio: 3 / 2,
          //         crossAxisSpacing: 20,
          //         mainAxisSpacing: 20,
          //       ),
          //       itemCount: photoMemoList.length,
          //       itemBuilder: (context, index) => Container(
          //         alignment: Alignment.center,
          //         child: MyImage.network(
          //           url: photoMemoList[index].photoURL,
          //           context: context,
          //         ),
          //       ),
          //     ),
          : ListView.builder(
              itemCount: photoMemoList.length,
              itemBuilder: (context, index) => Card(
                elevation: 7.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: MyImage.network(
                          url: photoMemoList[index].photoURL,
                          context: context,
                        ),
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
    // Navigator.pop(state.context);
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
}
