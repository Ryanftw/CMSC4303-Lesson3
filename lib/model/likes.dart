class Likes {
  String likeDocId;
  DateTime timestamp;
  String likeOn;
  String likedBy;
  String docId;
  String userProfilePic;

  static const DOC_ID = 'docId';
  static const LIKE_ON = 'likeOn';
  static const LIKED_BY = 'likedBy';
  static const LIKE_DOC_ID = 'likeDocId';
  static const TIMESTAMP = 'timestamp';
  static const USER_PROFILE_PIC = 'userProfilePic';

  Likes({
    this.likedBy,
    this.userProfilePic,
    this.likeDocId,
    this.likeOn,
    this.timestamp,
    this.docId,
  }) {}

  Likes.clone(Likes l) {
    this.likedBy = l.likedBy;
    this.userProfilePic = l.userProfilePic;
    this.likeDocId = l.likeDocId;
    this.likeOn = l.likeOn;
    this.timestamp = l.timestamp;
    this.docId = l.docId;
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      LIKED_BY: this.likedBy,
      USER_PROFILE_PIC: this.userProfilePic,
      LIKE_ON: this.likeOn,
      LIKE_DOC_ID: this.likeDocId,
      DOC_ID: this.docId,
      TIMESTAMP: this.timestamp,
    };
  }

  static Likes deserialize(Map<String, dynamic> doc, docId) {
    return Likes(
      likedBy: doc[LIKED_BY],
      docId: docId,
      userProfilePic: doc[USER_PROFILE_PIC],
      likeOn: doc[LIKE_ON],
      likeDocId: doc[LIKE_DOC_ID],
      timestamp: doc[TIMESTAMP] == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
    );
  }
}
