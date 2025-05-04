class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? country;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'country': country,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      dateOfBirth: map['dateOfBirth'],
      country: map['country'],
    );
  }
}
