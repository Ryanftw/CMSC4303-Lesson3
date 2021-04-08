class Comment {
  String comment;
  String docId;
  String commentBy;
  String commentDocId;
  DateTime timestamp;
  String userProfilePic;

  static const DOC_ID = 'docId';
  static const COMMENT = 'comment';
  static const COMMENT_BY = 'commentBy';
  static const COMMENT_DOC_ID = 'commentDocId'; // The url of the image stored in Firebase
  static const TIMESTAMP = 'timestamp';
  static const USER_PROFILE_PIC = 'userProfilePic';

  Comment({
    this.comment,
    this.userProfilePic,
    this.docId,
    this.commentBy,
    this.commentDocId,
    this.timestamp,
  }) {}

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      COMMENT: this.comment,
      DOC_ID: this.docId,
      USER_PROFILE_PIC: this.userProfilePic,
      COMMENT_BY: this.commentBy,
      COMMENT_DOC_ID: this.commentDocId,
      TIMESTAMP: this.timestamp,
    };
  }

  Comment.clone(Comment comment) {
    this.comment = comment.comment;
    this.docId = comment.docId;
    this.userProfilePic = comment.userProfilePic;
    this.commentBy = comment.commentBy;
    this.commentDocId = comment.commentDocId;
    this.timestamp = comment.timestamp;
  }

  void assign(Comment comment) {
    this.comment = comment.comment;
    this.userProfilePic = comment.userProfilePic;
    this.docId = comment.docId;
    this.commentBy = comment.commentBy;
    this.commentDocId = comment.commentDocId;
    this.timestamp = comment.timestamp;
  }

  static Comment deserialize(Map<String, dynamic> doc, String docId) {
    return Comment(
      comment: doc[COMMENT],
      userProfilePic: doc[USER_PROFILE_PIC],
      commentBy: doc[COMMENT_BY],
      docId: docId,
      commentDocId: doc[COMMENT_DOC_ID],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch,
            ),
    );
  }
}
