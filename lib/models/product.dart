import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String? productName;
  String? productDetails;
  String? email;
  String? price;
  String? phone;
  String? image1;
  String? image2;
  String? image3;
  String? status;
  String? created_at;
  String? updated_at;
  String? timestamp;
  
  ProductModel({
    this.productName,
    this.productDetails,
    this.email,
    this.price,
    this.phone,
    this.image1,
    this.image2,
    this.image3,
    this.status,
    this.created_at,
    this.updated_at,
    this.timestamp,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map<dynamic, dynamic>;
    return ProductModel(
      productName: data['productName'],
      productDetails: data['productDetail'],
      email: data['email'],
      price: data['price'],
      phone: data['phone'],
      image1: data['image-1'],
      image2: data['image-2'],
      image3: data['image-3'],
      status: data['status'],
      created_at: data['created_at'],
      updated_at: data['updated_at'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productDetails': productDetails,
      'email': email,
      'phone': phone,
      'image1': image1,
      'image2': image2,
      'image3': image3,
      'status': status,
      'created_at': created_at,
      'updated_at': updated_at,
      'timestamp': timestamp,
    };
  }
}
