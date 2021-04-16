import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:Assignment3/model/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'myview/mydialog.dart';
import 'myview/myimage.dart';


class FriendSearchScreen extends StatefulWidget {
  static const routeName = "/friendSearchScreen";
  @override
  State<StatefulWidget> createState() {
    return _FriendSearchState();
  }
}

class _FriendSearchState extends State<FriendSearchScreen> {
  _Controller con;
  User user;
  List<PhotoMemo> photoMemoList;
  List<Profile> profileList; 
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
    // Map args = ModalRoute.of(context).settings.arguments;
    // user ??= args[Constant.ARG_USER];
    // profile ??= args[Constant.ARG_ONE_PROFILE];
    // photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];

    return Scaffold(
        appBar: AppBar(
          actions: [
                Form(
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
                IconButton(icon: Icon(Icons.search), onPressed: con.search),
          ],
          title: Text("Text"),
        ),
        body: profileList != null ? ListView.builder(
              itemCount: profileList.length,
              itemBuilder: (context, index) => Stack(
                children: [
                  Card(
                    elevation: 7.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: profileList[index].url != null ? Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            decoration: BoxDecoration(shape: BoxShape.rectangle, image: DecorationImage(fit:BoxFit.fitWidth, image: NetworkImage(profileList[index].url))))
                            : Icon(Icons.person, size: 90.0,),
                          ),
                        Text("Name ${profileList[index].name}"),
                        Text("Age ${profileList[index].age}"),
                        Text("DisplayName ${profileList[index].displayName}"),
                        Text("Email ${profileList[index].email}"),
                      ],
                    ),
                  ),
                Positioned(top: 285.0, right: 25.0, child: Icon(Icons.check_box_outlined)),
                ],
              ),
        ) : Text("Search for Friends!"),

      );
  }
}

class _Controller {
  _FriendSearchState state;
  _Controller(this.state); 
  String keyString; 

  void search() async {
      state.formKey.currentState.save();
      var keys = keyString.split(',').toList();
      List<String> searchKeys = [];
      for (var k in keys) {
        if (k.trim().isNotEmpty) searchKeys.add(k.trim().toLowerCase());
      }
      if(searchKeys.isEmpty) return MyDialog.info(context: state.context, title: "Empty Search", content: "No search words found!!"); 
      try {
        List<Profile> results;
        results = await FirebaseController.searchProfile(
          searchKeys);
        state.render(() => state.profileList = results);
      } catch (e) {
        MyDialog.info(context: state.context, title: "Search error", content: "$e");
      }
    }

    void saveSearchKeyString(String value) {
      keyString = value; 
    }
}