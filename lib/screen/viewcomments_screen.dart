import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'addcomment_screen.dart';
import 'myview/myimage.dart';

class ViewCommentsScreen extends StatefulWidget {
  static const routeName = '/viewCommentsScreen';
  @override
  State<StatefulWidget> createState() {
    return _ViewCommentsState();
  }
}

class _ViewCommentsState extends State<ViewCommentsScreen> {
  _Controller con;
  User user;
  PhotoMemo onePhotoMemo;
  PhotoMemo onePhotoMemoTemp;
  List<Comment> commentList;

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
    commentList ??= args[Constant.ARG_COMMENTS];
    onePhotoMemo ??= args[Constant.ARG_ONE_PHOTOMEMO];
    onePhotoMemoTemp ??= PhotoMemo.clone(onePhotoMemo);
    return Scaffold(
      appBar: AppBar(
        title: Text("View Comments Screen"),
      ),
      body: commentList.length == 0
          ? Text(
              "No comments to display",
              style: Theme.of(context).textTheme.headline5,
            )
          : Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: MyImage.network(
                        url: onePhotoMemoTemp.photoURL,
                        context: context,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: commentList.length,
                    itemBuilder: (context, index) => Card(
                      elevation: 7.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  "${commentList[index].comment}",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Text(
                                  "${commentList[index].commentBy}",
                                  style: null,
                                ),
                                Text(
                                  "${commentList[index].timestamp}",
                                  style: null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Controller {
  _ViewCommentsState state;
  _Controller(this.state);
}
