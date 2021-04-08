class Profile {
  String docId;
  String profileFilename; // stored at Storage in firebase (non text database)
  String displayName;
  String email;
  String name;
  String url;
  String age;

  static const URL = 'url';
  static const PROFILE_FILENAME = 'profileFilename';
  static const DOC_ID = 'docId';
  static const NAME = 'name';
  static const EMAIL = 'email';
  static const AGE = 'age';
  static const DISPLAY_NAME = 'displayName';

  Profile({
    this.docId,
    this.profileFilename,
    this.url,
    this.displayName,
    this.name,
    this.email,
    this.age,
  }) {}

  Profile.clone(Profile p) {
    this.docId = p.docId;
    this.profileFilename = p.profileFilename;
    this.url = p.url;
    this.displayName = p.displayName;
    this.name = p.name;
    this.email = p.email;
    this.age = p.age;
  }

  void assign(Profile p) {
    this.docId = p.docId;
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
      URL: this.url,
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
      displayName: doc[DISPLAY_NAME],
      profileFilename: doc[PROFILE_FILENAME],
      email: doc[EMAIL],
      name: doc[NAME],
      age: doc[AGE],
    );
  }
}
