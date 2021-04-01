class Comment {
  String comment;
  String commentBy;
  String commentDocId;
  String photoCommentId;
  DateTime timestamp;

  static const COMMENT = 'comment';
  static const COMMENT_BY = 'commentBy';
  static const COMMENT_DOC_ID = 'commentDocId'; // the id of the image stored in firestore
  static const PHOTO_COMMENT_ID = 'photoCommentId';
  static const TIMESTAMP = 'timestamp';

  Comment({
    this.comment,
    this.commentBy,
    this.commentDocId,
    this.photoCommentId,
    this.timestamp,
  }) {}

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      COMMENT: this.comment,
      COMMENT_BY: this.commentBy,
      COMMENT_DOC_ID: this.commentDocId,
      TIMESTAMP: this.timestamp,
      PHOTO_COMMENT_ID: this.photoCommentId,
    };
  }

  static Comment deserialize(Map<String, dynamic> doc, String docId) {
    return Comment(
      photoCommentId: docId,
      comment: doc[COMMENT],
      commentBy: doc[COMMENT_BY],
      commentDocId: doc[COMMENT_DOC_ID],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch,
            ),
    );
  }
}
