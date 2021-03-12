import 'package:Assignment3/model/constant.dart';
import 'package:Assignment3/model/photomemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/Material.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';
  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  _Controller con;
  User user;
  PhotoMemo onePhotoMemo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    onePhotoMemo ??= args[Constant.ARG_ONE_PHOTOMEMO];
    return Scaffold(
      appBar: AppBar(
        title: Text("Detailed View"),
      ),
      body: Text(
        onePhotoMemo.imageLabels
            .join(' | '), // list of strings with labels joined by a bar
      ),
    );
  }
}

class _Controller {
  _DetailedViewState state;
  _Controller(this.state);
}
