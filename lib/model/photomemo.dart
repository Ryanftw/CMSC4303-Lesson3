enum MLAlgorithm {
  MLLabels,
  MLText,
}

enum Privacy {
  Public, 
  Private,
}

class PhotoMemo {  
  String docID; //Firestore auto generated id
  String createdBy;
  String memo; // actual contents of the memo
  String title;
  String photoFilename; // stored at Storage in firebase (non text database)
  String photoURL;
  bool public; 
  int likes;
  bool notification;
  bool likeNotification;
  DateTime lastViewed;
  DateTime likesLastViewed;
  DateTime timestamp;
  String labeler; 

  List<dynamic> likedBy;

  List<dynamic>
      sharedWith; // List of emails // dynamic because String is not compatible with Firestore, but dynamic is anything
  List<dynamic>
      imageLabels; // Image identified by Machine Learning from Firestore (will auto tag things like chair, wood, table, desk)

  // key for firestore document
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const PUBLIC = 'public'; 
  static const LABELER = 'labeler';
  static const CREATED_BY = 'createdBy';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_FILENAME = 'photoFilename';
  static const TIMESTAMP = 'timestamp';
  static const LAST_VIEWED = 'lastViewed';
  static const LIKES_LAST_VIEWED = 'likesLastViewed';
  static const SHARED_WITH = 'sharedWith';
  static const LIKED_BY = 'likedBy';
  static const LIKES = 'likes';
  static const IMAGE_LABELS = 'imageLabels';
  static const NOTIFICATION = 'notification';
  static const LIKE_NOTIFICATION = 'likeNotification';

  PhotoMemo({
    this.docID,
    this.likesLastViewed,
    this.likes,
    this.labeler,
    this.public,
    this.createdBy,
    this.likeNotification,
    this.memo,
    this.photoFilename,
    this.photoURL,
    this.timestamp,
    this.title,
    this.sharedWith,
    this.imageLabels,
    this.likedBy,
    this.lastViewed,
    this.notification,
  }) {
    this.likedBy ??= [];
    this.sharedWith ??= []; // if the list is null, start with an empty list.
    this.imageLabels ??= [];
  }

  PhotoMemo.clone(PhotoMemo p) {
    this.labeler = p.labeler;
    this.docID = p.docID;
    this.createdBy = p.createdBy;
    this.public = p.public;
    this.likesLastViewed = p.likesLastViewed;
    this.memo = p.memo;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.title = p.title;
    this.timestamp = p.timestamp;
    this.likeNotification = p.likeNotification;
    this.lastViewed = p.lastViewed;
    this.notification = p.notification;
    this.likes = p.likes;
    this.likedBy = [];
    this.likedBy.addAll(p.likedBy);
    this.sharedWith = [];
    this.sharedWith.addAll(p.sharedWith); // deep copy list
    this.imageLabels = [];
    this.imageLabels.addAll(p.imageLabels); // deep copy list
  }
// a = b ===> a.assign(b)
  void assign(PhotoMemo p) {
    this.docID = p.docID;
    this.labeler = p.labeler;
    this.public = p.public;
    this.likesLastViewed = p.likesLastViewed;
    this.createdBy = p.createdBy;
    this.likeNotification = p.likeNotification;
    this.memo = p.memo;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.title = p.title;
    this.timestamp = p.timestamp;
    this.lastViewed = p.lastViewed;
    this.notification = p.notification;
    this.likes = p.likes;
    this.likedBy.clear();
    this.likedBy.addAll(p.likedBy);
    this
        .sharedWith
        .clear(); // Clear first in case list has changed, then re-assign list values
    this.sharedWith.addAll(p.sharedWith); // deep copy list
    this
        .imageLabels
        .clear(); // Clear first in case list has changed, then re-assign list values
    this.imageLabels.addAll(p.imageLabels); // deep copy list
  }

// from Dart object to Firestore document. Converts dart object to compatible type with firestore
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      LIKED_BY: this.likedBy,
      LIKES: this.likes,
      LABELER: this.labeler, 
      PUBLIC: this.public,
      LIKES_LAST_VIEWED: this.likesLastViewed,
      LIKE_NOTIFICATION: this.likeNotification,
      TITLE: this.title,
      CREATED_BY: this.createdBy,
      MEMO: this.memo,
      PHOTO_FILENAME: this.photoFilename,
      PHOTO_URL: this.photoURL,
      TIMESTAMP: this.timestamp,
      SHARED_WITH: this.sharedWith,
      IMAGE_LABELS: this.imageLabels,
      LAST_VIEWED: this.lastViewed,
      NOTIFICATION: this.notification,
    };
  }

  static PhotoMemo deserialize(Map<String, dynamic> doc, String docId) {
    return PhotoMemo(
      docID: docId,
      labeler: doc[LABELER],
      likedBy: doc[LIKED_BY],
      likeNotification: doc[LIKE_NOTIFICATION],
      public: doc[PUBLIC],
      likes: doc[LIKES],
      createdBy: doc[CREATED_BY],
      title: doc[TITLE],
      memo: doc[MEMO],
      photoFilename: doc[PHOTO_FILENAME],
      photoURL: doc[PHOTO_URL],
      sharedWith: doc[SHARED_WITH],
      imageLabels: doc[IMAGE_LABELS],
      notification: doc[NOTIFICATION],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
      likesLastViewed: doc[LIKES_LAST_VIEWED] == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(
              doc[LIKES_LAST_VIEWED].millisecondsSinceEpoch),
      lastViewed: doc[LAST_VIEWED] == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(doc[LAST_VIEWED].millisecondsSinceEpoch),
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
