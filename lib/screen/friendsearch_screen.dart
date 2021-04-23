import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/profile.dart';
import 'package:Assignment3/screen/myview/myimage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'myview/mydialog.dart';


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
  List<Profile> profileList; 
  List<Profile> publicProfileList; 
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
    publicProfileList ??= args[Constant.ARG_FOLLOWING];
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
        body: profileList != null && profileList.length > 0 ? ListView.builder(//|| profileList.length > 0 ? ListView.builder(
              itemCount: profileList.length,
              itemBuilder: (context, index) => Stack(
                children: [
                  Card(
                    elevation: 7.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: profileList[index].url != "" ? Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(shape: BoxShape.circle,),
                            child: MyImage.network(url: profileList[index].url, context: context))// image: DecorationImage(fit:BoxFit.scaleDown, image: NetworkImage(publicProfileList[index].url))))
                            : Positioned(top: 90.0, right: 90, child: Icon(Icons.person, size: 90.0,),),
                          ),
                        Text("Name ${profileList[index].name}"),
                        Text("Age ${profileList[index].age}"),
                        Text("DisplayName ${profileList[index].displayName}"),
                        Text("Email ${profileList[index].email}"),
                      ],
                    ),
                  ),
                profile.following.contains(profileList[index].email) ?
                Positioned(top: 300.0, right: 160.0, child: IconButton(icon: Icon(Icons.check_box, color: Colors.blue[300],), onPressed: () => con.unFollow(index),),)
                : Positioned(top: 300.0, right: 160.0, child: IconButton(icon: Icon(Icons.check_box_outline_blank), onPressed: () => con.follow(index),),),
                profile.following.contains(profileList[index].email) ?
                Positioned(top: 300.0, right: 5.0, child: Text("Following!\nUncheck to unfollow.", style: TextStyle(color: Colors.blue[300]),),)
                : Positioned(top: 315.0, right: 5.0, child: Text("Check the box to follow!", style: TextStyle(color: Colors.blue[300]),),),
                ],
              ),
        ) : publicProfileList != null || publicProfileList.length > 0 ? ListView.builder(
              itemCount: publicProfileList.length,
              itemBuilder: (context, index) => Stack(
                children: [
                  Card(
                    elevation: 7.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: publicProfileList[index].url != "" ? Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.6,
                            // decoration: BoxDecoration(shape: BoxShape.circle,),
                            child: MyImage.network(url: publicProfileList[index].url, context: context))// image: DecorationImage(fit:BoxFit.scaleDown, image: NetworkImage(publicProfileList[index].url))))
                            : Positioned(top: 90.0, right: 90, child: Icon(Icons.person, size: 260.0,),),
                            //Icon(Icons.person, size: 90.0,),
                          ),
                        Text("Name ${publicProfileList[index].name}"),
                        Text("Age ${publicProfileList[index].age}"),
                        Text("DisplayName ${publicProfileList[index].displayName}"),
                        Text("Email ${publicProfileList[index].email}"),
                      ],
                    ),
                  ),
                profile.following.contains(publicProfileList[index].email) ?
                Positioned(top: 300.0, right: 160.0, child: IconButton(icon: Icon(Icons.check_box, color: Colors.blue[300],), onPressed: () => con.unFollow(index),),)
                : Positioned(top: 300.0, right: 160.0, child: IconButton(icon: Icon(Icons.check_box_outline_blank), onPressed: () => con.follow(index),),),
                profile.following.contains(publicProfileList[index].email) ?
                Positioned(top: 300.0, right: 5.0, child: Text("Following!\nUncheck to unfollow.", style: TextStyle(color: Colors.blue[300]),),)
                : Positioned(top: 315.0, right: 5.0, child: Text("Check the box to follow!", style: TextStyle(color: Colors.blue[300]),),),
                ],
              ),
        )
        : Text("Search for Friends!"),
      );
  }
}

class _Controller {
  _FriendSearchState state;
  _Controller(this.state); 
  String keyString; 

  void follow(int index) async {
    try {
      Map<String, dynamic> updateFollowing = {}; 
      state.profileList != null && state.profileList.length > 0 
      ? state.profile.following.add(state.profileList.elementAt(index).email)
      : state.profile.following.add(state.publicProfileList.elementAt(index).email);
      updateFollowing[Profile.FOLLOWING] = state.profile.following;  
      await FirebaseController.updateFollowing(state.profile.docId, updateFollowing); 
      state.render(() {});
    } catch (e) {
      MyDialog.info(context: state.context, title: "Follow Error", content: e.toString());
    }
  }

  void unFollow(int index) async {
    try {
      Map<String, dynamic> updateFollowing = {}; 
      state.profileList != null && state.profileList.length > 0
      ? state.profile.following.removeWhere((element) => element == state.profileList.elementAt(index).email)
      : state.profile.following.removeWhere((element) => element == state.publicProfileList.elementAt(index).email);
      updateFollowing[Profile.FOLLOWING] = state.profile.following; 
      await FirebaseController.updateFollowing(state.profile.docId, updateFollowing); 
      state.render(() {});
    } catch (e) {
      MyDialog.info(context: state.context, title: "Follow Error", content: e.toString());
    }
    
  }

  void search() async {
      state.formKey.currentState.save();
      // var keys = keyString.split(',').toList();
      // List<String> searchKeys = [];
      // for (var k in keys) {
        // if (k.trim().isNotEmpty) searchKeys.add(k.trim().toLowerCase());
      // }
      state.profileList = []; 
      List<Profile> temp = []; 
      if(keyString.isEmpty) return;// MyDialog.info(context: state.context, title: "Empty Search", content: "No search words found!!"); 
      state.publicProfileList.forEach((element) {
        if(element.displayName.contains(keyString) || element.name.contains(keyString) || element.email.contains(keyString)) {
          temp.add(element);
        }
      });
      state.profileList.clear(); 
      List<Profile> tempProfile = [];
      if(temp.isEmpty) {
        tempProfile = await FirebaseController.searchProfile(keyString);
      } else {
        state.profileList.addAll(temp); 
      }
      if(tempProfile.isNotEmpty)
      state.profileList.addAll(tempProfile);
      state.render(() {});
    }

    void saveSearchKeyString(String value) {
      keyString = value; 
    }
}