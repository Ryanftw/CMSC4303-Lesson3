class PhotoMemo {
  String docID; //Firestore auto generated id
  String createdBy;
  String memo; // actual contents of the memo
  String title;
  String photoFilename; // stored at Storage in firebase (non text database)
  String photoURL;
  DateTime timestamp;
  List<dynamic>
      sharedWith; // List of emails // dynamic because String is not compatible with Firestore, but dynamic is anything
  List<dynamic>
      imageLabels; // Image identified by Machine Learning from Firestore (will auto tag things like chair, wood, table, desk)

  // key for firestore document
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const CREATED_BY = 'createdBy';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_FILENAME = 'photoFilename';
  static const TIMESTAMP = 'timestamp';
  static const SHARED_WITH = 'sharedWith';
  static const IMAGE_LABELS = 'imageLabels';

  PhotoMemo({
    this.docID,
    this.createdBy,
    this.memo,
    this.photoFilename,
    this.photoURL,
    this.timestamp,
    this.title,
    this.sharedWith,
    this.imageLabels,
  }) {
    this.sharedWith ??= []; // if the list is null, start with an empty list.
    this.imageLabels ??= [];
  }

// from Dart object to Firestore document. Converts dart object to compatible type with firestore
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      TITLE: this.title,
      CREATED_BY: this.createdBy,
      MEMO: this.memo,
      PHOTO_FILENAME: this.photoFilename,
      PHOTO_URL: this.photoURL,
      TIMESTAMP: this.timestamp,
      SHARED_WITH: this.sharedWith,
      IMAGE_LABELS: this.imageLabels,
    };
  }

  static PhotoMemo deserialize(Map<String, dynamic> doc, String docId) {
    return PhotoMemo(
      docID: docId,
      createdBy: doc[CREATED_BY],
      title: doc[TITLE],
      memo: doc[MEMO],
      photoFilename: doc[PHOTO_FILENAME],
      photoURL: doc[PHOTO_URL],
      sharedWith: doc[SHARED_WITH],
      imageLabels: doc[IMAGE_LABELS],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
    );
  }

  static String validateTitle(String value) {
    if (value == null || value.length < 3)
      return 'too short';
    else
      return null;
  }

  static String validateMemo(String value) {
    if (value == null || value.length < 5)
      return 'too short';
    else
      return null;
  }

  static String validateSharedWith(String value) {
    if (value == null || value.trim().length == 0) return null;
    List<String> emailList = value
        .split(RegExp('(,| )+'))
        .map((e) => e.trim())
        .toList(); // (,| )+ --> Notation for the regular expression inside of parenthesis
    // (,| )+ inside parenthesis is split by the vertical bar, + means multiple of what is inside parenthesis
    for (String email in emailList) {
      if (email.contains("@") && email.contains("."))
        continue;
      else
        return 'Comma(,) or space separated email list';
    }
    return null;
  }
}
