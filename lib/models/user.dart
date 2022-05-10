import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? userName;
  String? userEmail;
  String? imageUrl;
  String? uid;
  String? joiningDate;

  User({
    this.userName,
    this.userEmail,
    this.imageUrl,
    this.uid,
    this.joiningDate,
  });


  factory User.fromFirestore(DocumentSnapshot snapshot){
    Map d = snapshot.data() as Map<dynamic, dynamic>;
    return User(
      userName: d['name'] ?? '',
      userEmail: d['email'] ?? '',
      imageUrl: d['image url'] ?? 'https://www.seekpng.com/png/detail/115-1150053_avatar-png-transparent-png-royalty-free-default-user.png',
      uid: d['uid'] ?? '',
      joiningDate: d['joining date'] ?? '',
    );
  }
}