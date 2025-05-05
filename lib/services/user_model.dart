class UserModel {
  final String uid;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? gender;
  final String? country;
  final String? phoneNumber;
  final String? birthdate;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.gender,
    this.country,
    this.phoneNumber,
    this.birthdate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      bio: map['bio'],
      gender: map['gender'],
      country: map['country'],
      phoneNumber: map['phoneNumber'],
      birthdate: map['birthdate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'gender': gender,
      'country': country,
      'phoneNumber': phoneNumber,
      'birthdate': birthdate,
    };
  }
}
