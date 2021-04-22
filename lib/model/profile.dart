class Profile {
  String docId;
  String profileFilename; // stored at Storage in firebase (non text database)
  String displayName;
  String email;
  String name;
  bool profilePublic; 
  String url;
  String age;

  List<dynamic> followers; 
  List<dynamic> following; 

  static const URL = 'url';
  static const PROFILE_FILENAME = 'profileFilename';
  static const DOC_ID = 'docId';
  static const NAME = 'name';
  static const EMAIL = 'email';
  static const PROFILE_PUBLIC = 'profilePublic'; 
  static const FOLLOWERS = 'followers';
  static const FOLLOWING = 'following';
  static const AGE = 'age';
  static const DISPLAY_NAME = 'displayName';

  Profile({
    this.docId,
    this.profilePublic,
    this.profileFilename,
    this.url,
    this.displayName,
    this.followers,
    this.following,
    this.name,
    this.email,
    this.age,
  }) {
    this.followers ??= []; 
    this.following ??= []; 
  }

  Profile.clone(Profile p) {
    this.docId = p.docId;
    this.profileFilename = p.profileFilename;
    this.url = p.url;
    this.profilePublic = p.profilePublic;
    this.followers = p.followers;
    this.following = p.following;
    this.displayName = p.displayName;
    this.name = p.name;
    this.email = p.email;
    this.age = p.age;
  }

  void assign(Profile p) {
    this.docId = p.docId;
    this.profilePublic = p.profilePublic;
    this.following = p.following;
    this.followers = p.followers;
    this.profileFilename = p.profileFilename;
    this.url = p.url;
    this.displayName = p.displayName;
    this.name = p.name;
    this.email = p.email;
    this.age = p.age;
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      DISPLAY_NAME: this.displayName,
      PROFILE_PUBLIC: this.profilePublic,
      URL: this.url,
      FOLLOWERS: this.followers, 
      FOLLOWING: this.following,
      PROFILE_FILENAME: this.profileFilename,
      DOC_ID: this.docId,
      EMAIL: this.email,
      NAME: this.name,
      AGE: this.age,
    };
  }

  static Profile deserialize(Map<String, dynamic> doc, String docId) {
    return Profile(
      docId: docId,
      url: doc[URL],
      profilePublic: doc[PROFILE_PUBLIC],
      displayName: doc[DISPLAY_NAME],
      followers: doc[FOLLOWERS],
      following: doc[FOLLOWING],
      profileFilename: doc[PROFILE_FILENAME],
      email: doc[EMAIL],
      name: doc[NAME],
      age: doc[AGE],
    );
  }
}
