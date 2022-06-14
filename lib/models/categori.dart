
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesModel {
  String? title;
  String? created_at;
  String? updated_at;
  String? timestamp;

  CategoriesModel({
    this.title,
    this.created_at,
    this.updated_at,
    this.timestamp    
  });

  factory CategoriesModel.fromFirestore(DocumentSnapshot snapshot){
    Map d = snapshot.data() as Map<dynamic, dynamic>;
    return CategoriesModel  (
      title: d['title'],
      created_at: d['created_at'],
      updated_at: d['updated_at'],
      timestamp: d['timestamp'],
    );
  }
}