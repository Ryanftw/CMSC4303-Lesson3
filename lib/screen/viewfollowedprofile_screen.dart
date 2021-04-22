import 'package:Assignment3/controller/firebasecontroller.dart';
import 'package:Assignment3/model/comment.dart';
import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/likes.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:Assignment3/model/profile.dart';
import 'package:Assignment3/screen/viewcomments_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/Material.dart';

import 'addcomment_screen.dart';
import 'myview/mydialog.dart';
import 'myview/myimage.dart';

class ViewFollowedProfileScreen extends StatefulWidget {
  static const routeName = '/viewFollowedProfileScreen'; 
  @override
  State<StatefulWidget> createState() {
    return _ViewFollowedProfileState(); 
  }
}

class _ViewFollowedProfileState extends State<ViewFollowedProfileScreen> {
  _Controller con; 
  Profile profile; 
  List<PhotoMemo> photoMemoList; 
  User user; 
  PhotoMemo tempPhotoMemo;
  List<Likes> userLikes;
  bool flag = false;

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
    profile ??= args[Constant.ARG_ONE_PROFILE]; 
    return Scaffold(
      appBar: AppBar(
        title: Text("Following"),
      ),
      body: Stack(
                children: [
                  // Positioned(
                  //   top: 20.0,
                  //   right: 325.0,
                  //   child: IconButton(icon: Icon(Icons.person_search, size: 30.0,), onPressed: con.searchFriends,),
                  // ),
                  // Positioned(
                  //   top: 65.0,
                  //   right: 305.0,
                  //   child: Text("Search for\nfriends!"),
                  // ),
                  // Positioned(
                  //   top: 215.0,
                  //   right: 315.0,
                  //   child: IconButton(icon: Icon(Icons.people, size: 40.0, color: Colors.blue[300],), onPressed: con.followingPage,),
                  // ),
                  // Positioned(
                  //   top: 265.0,
                  //   right: 305.0,
                  //   child: Text("Following"),
                  // ),
                  Positioned(
                    top: 210.0,
                    right: 178.0,
                    child: Text(profile.displayName, style: TextStyle(color: Colors.blue[300]),),
                  ),
                  Positioned(
                    top: 230.0,
                    right: 182.0,
                    child: Text("Age ${profile.age}", style: TextStyle(color: Colors.blue[300]),),
                  ),
                  Positioned(
                    top: 25.0,
                    right: 162.0,
                    child: Text(profile.email, style: TextStyle(color: Colors.blue[300]),),
                  ),
                  Column(
                    children: [
                      Expanded(
                        flex: 2,
                         child: Center(
                          child: profile.url != null ?
                          Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(fit:BoxFit.scaleDown, image: NetworkImage(profile.url))),
                          ) : Icon(Icons.person, size: 300,),
                        ),
                      ),
                    Divider(height: 1.0, color: Colors.blue[300], indent: 40.0, endIndent: 40.0, thickness: 0.3,),
                    photoMemoList.length == 0
                    ? Expanded(
                        flex: 4,
                        child: Text(
                         "No Photomemos Found!", 
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      )
                    : Expanded(
                      flex: 4,
                      child: ListView.builder(
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
                                      onDoubleTap: () => con.thumbsUp(index),
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
                    ),
        ],),
                ]),);
      // body: followingList.isNotEmpty ? GridView.builder(
      //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      //     maxCrossAxisExtent: 200,
      //     childAspectRatio: 3 / 2,
      //     crossAxisSpacing: 20,
      //     mainAxisSpacing: 20
      //   ),
      //   itemCount: followingList.length,
      //   itemBuilder: (context, index) => Stack(
      //           children: [
      //             Card(
      //               elevation: 7.0,
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Center(
      //                     child: followingList[index] != null ? GestureDetector(
      //                       child: Container(
      //                         height: MediaQuery.of(context).size.height * 0.3,
      //                         width: MediaQuery.of(context).size.width * 0.6,
      //                         decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(fit:BoxFit.scaleDown, image: NetworkImage(followingList.elementAt(index).url),)),
      //                       ),
      //                       onTap: null,//() => con.followingSharedWith(index),
      //                     )
      //                       : Icon(Icons.person, size: 90.0,),
      //                     ),
      //                   Text("Name ${followingList[index].name}"),
      //                   Text("Age ${followingList[index].age}"),
      //                   Text("DisplayName ${followingList[index].displayName}"),
      //                   Text("Email ${followingList[index].email}"),
      //                 ],
      //               ),
      //             ),
      //           profile.following.contains(followingList[index].email) ?
      //           Positioned(top: 300.0, right: 160.0, child: IconButton(icon: Icon(Icons.check_box, color: Colors.blue[300],), onPressed: null,))// con.unFollow,),)
      //           : Positioned(top: 300.0, right: 160.0, child: IconButton(icon: Icon(Icons.check_box_outline_blank), onPressed: null),),// con.follow,),),
      //           profile.following.contains(followingList[index].email) ?
      //           Positioned(top: 300.0, right: 5.0, child: Text("Following!\nUncheck to unfollow.", style: TextStyle(color: Colors.blue[300]),),)
      //           : Positioned(top: 315.0, right: 5.0, child: Text("Check the box to follow!", style: TextStyle(color: Colors.blue[300]),),),
      //           ],
      //         ),
      
      
    //   body: followingList.isNotEmpty ? ListView.builder(
    //           itemCount: followingList.length,
    //           itemBuilder: (context, index) => Stack(
    //             children: [
    //               Card(
    //                 elevation: 7.0,
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Center(
    //                       child: followingList[index] != null ? GestureDetector(
    //                         child: Container(
    //                           height: MediaQuery.of(context).size.height * 0.3,
    //                           width: MediaQuery.of(context).size.width * 0.6,
    //                           decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(fit:BoxFit.scaleDown, image: NetworkImage(followingList.elementAt(index).url),)),
    //                         ),
    //                         onTap: null,//() => con.followingSharedWith(index),
    //                       )
    //                         : Icon(Icons.person, size: 90.0,),
    //                       ),
    //                     Text("Name ${followingList[index].name}"),
    //                     Text("Age ${followingList[index].age}"),
    //                     Text("DisplayName ${followingList[index].displayName}"),
    //                     Text("Email ${followingList[index].email}"),
    //                   ],
    //                 ),
    //               ),
    //             profile.following.contains(followingList[index].email) ?
    //             Positioned(top: 300.0, right: 160.0, child: IconButton(icon: Icon(Icons.check_box, color: Colors.blue[300],), onPressed: null,))// con.unFollow,),)
    //             : Positioned(top: 300.0, right: 160.0, child: IconButton(icon: Icon(Icons.check_box_outline_blank), onPressed: null),),// con.follow,),),
    //             profile.following.contains(followingList[index].email) ?
    //             Positioned(top: 300.0, right: 5.0, child: Text("Following!\nUncheck to unfollow.", style: TextStyle(color: Colors.blue[300]),),)
    //             : Positioned(top: 315.0, right: 5.0, child: Text("Check the box to follow!", style: TextStyle(color: Colors.blue[300]),),),
    //             ],
    //           ),
    //     ) : Text("Not Following Anyone!!!"),
    // );
  }
}


class _Controller {
    _ViewFollowedProfileState state; 
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