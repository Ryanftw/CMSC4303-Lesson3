class Profile {
  String docId;
  String email;
  String name;
  String age;

  static const EMAIL = 'email';
  static const DOC_ID = 'docId';
  static const NAME = 'name';
  static const AGE = 'age';

  Profile({
    this.docId,
    this.email,
    this.name,
    this.age,
  }) {}

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      DOC_ID: this.docId,
      EMAIL: this.email,
      NAME: this.name,
      AGE: this.age,
    };
  }

  static Profile deserialize(Map<String, dynamic> doc, String docId) {
    return Profile(
      docId: docId,
      email: doc[EMAIL],
      name: doc[NAME],
      age: doc[AGE],
    );
  }
}
