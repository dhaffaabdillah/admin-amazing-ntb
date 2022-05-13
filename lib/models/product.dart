import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String? productName;
  String? productDetails;
  String? authorId;
  int? price;
  String? sellerContact;
  String? image1;
  String? image2;
  String? image3;
  String? status;
  String? created_at;
  String? updated_at;
  ProductModel({
    this.productName,
    this.productDetails,
    this.authorId,
    this.price,
    this.sellerContact,
    this.image1,
    this.image2,
    this.image3,
    this.status,
    this.created_at,
    this.updated_at,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map<dynamic, dynamic>;
    return ProductModel(
      productName: data['productName'],
      productDetails: data['productDetails'],
      // authorId: data['authorId'],
      // price: data['price'],
      sellerContact: data['sellerContact'],
      image1: data['image1'],
      image2: data['image2'],
      image3: data['image3'],
      status: data['status'],
      created_at: data['created_at'],
      updated_at: data['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productDetails': productDetails,
      // 'price': price,
      'sellerContact': sellerContact,
      'image1': image1,
      'image2': image2,
      'image3': image3,
      'status': status,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
