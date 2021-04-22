import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/likes.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:Assignment3/model/profile.dart';
import 'package:Assignment3/screen/viewfollowedprofile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/Material.dart';

import 'myview/myimage.dart';

class ViewFollowingScreen extends StatefulWidget {
  static const routeName = 'viewFollowingScreen';
  @override
  State<StatefulWidget> createState() {
    return _ViewFollowingState(); 
  }
}

class _ViewFollowingState extends State<ViewFollowingScreen> {
  _Controller con; 
  List<Profile> followingList; 
  User user; 
  Profile profile; 

  @override
  void initState() {
    super.initState();
    con = _Controller(this); 
  }

  void render(fn) => setState(fn); 

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    followingList ??= args[Constant.ARG_FOLLOWING];
    user ??= args[Constant.ARG_USER];
    profile ??= args[Constant.ARG_ONE_PROFILE];
    return Scaffold(
      appBar: AppBar(
        title: Text("View Following"),
      ),
      body: followingList.isNotEmpty ? GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20
        ),
        itemCount: followingList.length,
        itemBuilder: (context, index) => Stack(
                children: [
                  Card(
                    elevation: 7.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: followingList[index] != null ? GestureDetector(
                            child: Container(
                              height: 150.0,// MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width * 0.6,
                              // decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(fit:BoxFit.scaleDown, image: NetworkImage(followingList.elementAt(index).url),)),
                              child: MyImage.network(url: followingList[index].url, context: context),
                            ),
                            onTap: () => con.followingSharedWith(index),
                          )
                            : Icon(Icons.person, size: 90.0,),
                        ),
                        Text("Name: ${followingList[index].name}"),
                        Text("Age: ${followingList[index].age}"),
                        Text("DisplayName: ${followingList[index].displayName}"),
                        Text("Email: ${followingList[index].email}"),
                      ],
                    ),
                  ),
                profile.following.contains(followingList[index].email) ?
                Positioned(top: 255.0, right: 157.0, child: IconButton(icon: Icon(Icons.check_box, color: Colors.blue[300],), onPressed: null,))// con.unFollow,),)
                : Positioned(top: 255.0, right: 157.0, child: IconButton(icon: Icon(Icons.check_box_outline_blank), onPressed: null),),// con.follow,),),
                profile.following.contains(followingList[index].email) ?
                Positioned(top: 255.0, right: 2.0, child: Text("Following!\nUncheck to unfollow.", style: TextStyle(color: Colors.blue[300]),),)
                : Positioned(top: 260.0, right: 2.0, child: Text("Check the box\nto follow!", style: TextStyle(color: Colors.blue[300]),),),
                ],
              ),
        ) : Text("Not Following Anyone!!!"),
    );
  }
}

class _Controller {
  _ViewFollowingState state; 
  _Controller(this.state); 

  void followingSharedWith(int index) async {
    List<Likes> userLikes = await FirebaseController.getUserSharedLikes(email: state.user.email);
    List<PhotoMemo> photoMemoList = await FirebaseController.getFollowedMemos(state.user.email, state.followingList.elementAt(index).email);
    Navigator.pushNamed(state.context, ViewFollowedProfileScreen.routeName, arguments: {
      Constant.ARG_PHOTOMEMOLIST: photoMemoList, Constant.ARG_ONE_PROFILE: state.followingList.elementAt(index), Constant.ARG_USER: state.user, Constant.ARG_LIKES: userLikes,
    });
  }
}
