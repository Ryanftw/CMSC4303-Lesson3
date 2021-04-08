import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/likes.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:Assignment3/model/profile.dart';
import 'package:Assignment3/screen/addphotomemo_screen.dart';
import 'package:Assignment3/screen/profilesettings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'detailedview_screen.dart';
import 'myview/mydialog.dart';
import 'myview/myimage.dart';
import 'sharedwith_screen.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = "/userHomeScreen";
  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  _Controller con;
  User user;
  List<PhotoMemo> photoMemoList;
  Profile profile;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    profile ??= args[Constant.ARG_ONE_PROFILE];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];

    return WillPopScope(
      onWillPop: () => Future.value(false), // Android back button disabled
      child: Scaffold(
        appBar: AppBar(
          actions: [
            con.delIndex != null
                ? IconButton(icon: Icon(Icons.cancel), onPressed: con.cancelDelete)
                : Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: "Search",
                            fillColor: Theme.of(context).backgroundColor,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKeyString,
                        ),
                      ),
                    ),
                  ),
            con.delIndex != null
                ? IconButton(icon: Icon(Icons.delete), onPressed: con.delete)
                : IconButton(icon: Icon(Icons.search), onPressed: con.search),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: profile.url == null
                    ? Icon(
                        Icons.person,
                        size: 100.0,
                      )
                    : profile.url == ""
                        ? Icon(
                            Icons.person,
                            size: 100.0,
                          )
                        : MyImage.network(
                            url: profile.url,
                            context: context,
                          ),
                accountName: profile.displayName == null
                    ? Text("Not set")
                    : Text("${profile.displayName}"),
                accountEmail: Text(user.email),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text("Shared With Me"),
                onTap: con.sharedWithMe,
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                onTap: con.settings,
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Sign out"),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: photoMemoList.length == 0
            ? Text(
                "No PhotoMemos Found!",
                style: Theme.of(context).textTheme.headline5,
              )
            : ListView.builder(
                itemCount: photoMemoList.length,
                itemBuilder: (BuildContext context, int index) => Stack(
                  children: [
                    Container(
                      color: con.delIndex != null && con.delIndex == index
                          ? Theme.of(context).highlightColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      child: ListTile(
                        leading: MyImage.network(
                          url: photoMemoList[index].photoURL,
                          context: context,
                        ), // leading parameter of listTile
                        trailing: Icon(Icons.keyboard_arrow_right),
                        title: Text(photoMemoList[index].title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(photoMemoList[index].memo.length >= 20
                                ? photoMemoList[index].memo.substring(0, 20) + '...'
                                : photoMemoList[index].memo),
                            Text('Created By: ${photoMemoList[index].createdBy}'),
                            Text('Shared with: ${photoMemoList[index].sharedWith}'),
                            Text('Updated At: ${photoMemoList[index].timestamp}'),
                          ],
                        ),
                        onTap: () => con.onTap(index),
                        onLongPress: () => con.onLongPress(index),
                      ),
                    ),

                    // : GridView.builder(
                    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //         crossAxisCount: 2,
                    //         mainAxisSpacing: 2,
                    //         crossAxisSpacing: 1,
                    //         childAspectRatio: 1),
                    //     itemCount: photoMemoList.length,
                    //     itemBuilder: (context, index) => Stack(
                    //       children: [
                    //         Expanded(
                    //           flex: 1,
                    //           child: GestureDetector(
                    //             child: Center(
                    //               child: Container(
                    //                 child: MyImage.network(
                    //                   url: photoMemoList[index].photoURL,
                    //                   context: context,
                    //                 ),
                    //               ),
                    //             ),
                    //             onTap: () => con.onTap(index),
                    //             onLongPress: () => con.onLongPress(index),
                    //           ),
                    //         ),
                    photoMemoList[index].notification == true
                        ? Positioned(
                            top: 40.0,
                            right: 1.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.chat,
                                color: Colors.yellow,
                              ),
                              onPressed: null,
                              iconSize: 30,
                            ),
                          )
                        : Positioned(
                            bottom: 10.0,
                            right: 10.0,
                            child: (SizedBox(
                              height: 1.0,
                            )),
                          ),
                    photoMemoList[index].likeNotification == true
                        ? Positioned(
                            top: 65.0,
                            right: 1.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.thumb_up,
                                color: Colors.blue,
                              ),
                              onPressed: null,
                              iconSize: 30,
                            ),
                          )
                        : Positioned(
                            top: 65.0,
                            right: 1.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.thumb_up_outlined,
                                color: Colors.blue,
                              ),
                              onPressed: null,
                              iconSize: 30,
                            ),
                          ),
                    photoMemoList[index].likedBy.isEmpty
                        ? Positioned(
                            bottom: 10.0,
                            right: 10.0,
                            child: (SizedBox(
                              height: 1.0,
                            )),
                          )
                        : Positioned(
                            top: 87.0,
                            right: 19.0,
                            child: Text(
                              "${photoMemoList[index].likedBy.length}",
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            ))
                  ],
                ),
              ),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  _Controller(this.state);
  int delIndex;
  String keyString;

  void addButton() async {
    await Navigator.pushNamed(
      state.context,
      AddPhotoMemoScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: state.photoMemoList,
      },
    );
    state.render(() {}); //re render the screen
  }

  void signOut() async {
    try {
      await FirebaseController.signOut();
    } catch (e) {
      // do nothing

    }
    Navigator.of(state.context).pop(); // close the drawer
    Navigator.of(state.context)
        .pop(); // pop UserHome Screen and go back to sign in screen.
  }

  void onTap(int index) async {
    if (delIndex != null) return;
    List<Comment> cList = await FirebaseController.getCommentList(
        docId: state.photoMemoList[index].photoURL);
    await Navigator.pushNamed(
      state.context,
      DetailedViewScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
        // Constant.ARG_LIKES: state.userLikes,
        Constant.ARG_COMMENTS: cList,
      },
    );
    state.render(() {});
  }

  void sharedWithMe() async {
    try {
      List<PhotoMemo> photoMemoList = await FirebaseController.getPhotoMemoSharedWithMe(
        email: state.user.email,
      );
      List<Likes> userLikes =
          await FirebaseController.getUserSharedLikes(email: state.user.email);
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName, arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: photoMemoList,
        Constant.ARG_LIKES: userLikes,
      });
      Navigator.pop(state.context); //closes the drawer
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'get Shared PhotoMemo error',
        content: '$e',
      );
    }
  }

  void onLongPress(int index) {
    if (delIndex != null) return;
    state.render(() => delIndex = index);
  }

  void cancelDelete() {
    state.render(() => delIndex = null);
  }

  void settings() async {
    await Navigator.pushNamed(state.context, ProfileSettingsScreen.routeName, arguments: {
      Constant.ARG_USER: state.user,
      Constant.ARG_ONE_PROFILE: state.profile,
    });
    Navigator.pop(state.context);
    state.render(() {});
  }

  void delete() async {
    try {
      PhotoMemo p = state.photoMemoList[delIndex];
      await FirebaseController.deletePhotoLikes(p.photoURL);
      await FirebaseController.deletePhotoMemo(p);
      await FirebaseController.deletePhotoMemoComments(docId: p.photoURL);
      state.render(() {
        state.photoMemoList.removeAt(delIndex);
        delIndex = null;
      });
    } catch (e) {
      MyDialog.info(
          context: state.context, title: 'Delete PhotoMemo error', content: '$e');
    }
  }

  void saveSearchKeyString(String value) {
    keyString = value;
  }

  void search() async {
    state.formKey.currentState.save();
    var keys = keyString.split(',').toList();
    List<String> searchKeys = [];
    for (var k in keys) {
      if (k.trim().isNotEmpty) searchKeys.add(k.trim().toLowerCase());
    }
    try {
      List<PhotoMemo> results;
      if (searchKeys.isNotEmpty) {
        results = await FirebaseController.searchImage(
          createdBy: state.user.email,
          searchLabels: searchKeys,
        );
      } else {
        results = await FirebaseController.getPhotoMemoList(email: state.user.email);
      }
      state.render(() => state.photoMemoList = results);
    } catch (e) {
      MyDialog.info(context: state.context, title: "Search error", content: "$e");
    }
  }
}
