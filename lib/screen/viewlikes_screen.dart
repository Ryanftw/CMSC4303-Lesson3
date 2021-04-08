import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/likes.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'myview/myimage.dart';

class ViewLikesScreen extends StatefulWidget {
  static const routeName = '/viewLikesScreen';
  @override
  State<StatefulWidget> createState() {
    return _ViewLikesState();
  }
}

class _ViewLikesState extends State<ViewLikesScreen> {
  _Controller con;
  User user;
  PhotoMemo onePhotoMemo;
  List<Likes> likeList;

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
    likeList ??= args[Constant.ARG_LIKES];
    onePhotoMemo ??= args[Constant.ARG_ONE_PHOTOMEMO];
    return Scaffold(
      appBar: AppBar(
        title: Text("View Likes Screen"),
      ),
      body: likeList.length == 0
          ? Text(
              "No Likes to display",
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
                        url: onePhotoMemo.photoURL,
                        context: context,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: likeList.length,
                    itemBuilder: (context, index) => Card(
                      elevation: 7.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Center(
                          // child: Column(
                          Row(
                            children: [
                              Text(
                                "${likeList[index].likedBy}",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Text(
                                "${likeList[index].timestamp}",
                                style: null,
                              ),
                              SizedBox(
                                height: 40,
                                width: 15.0,
                              ),
                              likeList[index].userProfilePic == null
                                  ? SizedBox(height: 1.0)
                                  : Container(
                                      height: 40,
                                      width: 40,
                                      child: MyImage.network(
                                          url: likeList[index].userProfilePic,
                                          context: context),
                                    ),
                            ],
                          ),
                          // ),
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
  _ViewLikesState state;
  _Controller(this.state);
}
