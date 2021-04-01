import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:Assignment3/screen/addphotomemo_screen.dart';
import 'package:Assignment3/screen/profilesettings_screen.dart';
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
  String profileURL;
  User user;
  List<PhotoMemo> photoMemoList;
  // List<Comment> commentList;
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
    // commentList ??= args[Constant.ARG_COMMENTS];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    // profileURL = user.photoURL;

    return WillPopScope(
      onWillPop: () => Future.value(false), // Android back button disabled
      child: Scaffold(
        appBar: AppBar(
          // title: Text("User Home"),
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
                currentAccountPicture: user.photoURL == null
                    ? Icon(
                        Icons.person,
                        size: 100.0,
                      )
                    : MyImage.network(
                        url: user.photoURL,
                        context: context,
                      ),
                accountName: user.displayName == null
                    ? Text("Not set")
                    : Text("${user.displayName}"),
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
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 1,
                    childAspectRatio: 1.25),
                itemCount: photoMemoList.length,
                itemBuilder: (context, index) => Stack(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 1,
                        width: MediaQuery.of(context).size.width * 1,
                        child: RaisedButton.icon(
                          color: Colors.grey[800],
                          // alignment: Alignment.center,
                          icon: MyImage.network(
                            url: photoMemoList[index].photoURL,
                            context: context,
                          ),
                          label: Text(
                            "",
                          ),
                          onLongPress: () => con.onLongPress(index),
                          onPressed: () => con.onTap(index),
                        ),
                      ),
                    ),
                    photoMemoList[index].notification == true
                        ? Positioned(
                            top: 1.0,
                            right: 1.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.chat,
                                color: Colors.yellow,
                              ),
                              onPressed: null,
                              iconSize: 18,
                            ),
                          )
                        : Positioned(
                            bottom: 10.0,
                            right: 10.0,
                            child: (SizedBox(
                              height: 1.0,
                            )),
                          ),
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
    await Navigator.pushNamed(
      state.context,
      DetailedViewScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
      },
    );
    state.render(() {});
  }

  void sharedWithMe() async {
    try {
      List<PhotoMemo> photoMemoList = await FirebaseController.getPhotoMemoSharedWithMe(
        email: state.user.email,
      );
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName, arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: photoMemoList,
      });
      Navigator.pop(state.context); //closes the draw
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

  void settings() {
    Navigator.pushNamed(state.context, ProfileSettingsScreen.routeName, arguments: {
      Constant.ARG_USER: state.user,
    });
  }

  void delete() async {
    try {
      PhotoMemo p = state.photoMemoList[delIndex];
      await FirebaseController.deletePhotoMemo(p);
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
