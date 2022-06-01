import 'dart:typed_data';

import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/constants/constants.dart';
import 'package:admin/models/blog.dart';
import 'package:admin/models/product.dart';
import 'package:admin/utils/cached_image.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/styles.dart';
import 'package:admin/widgets/product_preview.dart';
import 'package:admin/widgets/cover_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateProduct extends StatefulWidget {
  final ProductModel productData;
  UpdateProduct({Key? key, required this.productData}) : super(key: key);

  @override
  _UpdateProductState createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();

  var productNameCtrl = TextEditingController();
  var productDetailCtrl = TextEditingController();
  var sellerContact = TextEditingController();
  var priceCtrl = TextEditingController();

  Uint8List? thumbnail, img1, img2;
  String oldThumbnailName = "", oldImg1Name = "", oldImg2Name = "";

  var statusSelection;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  //bool notifyUsers = true;
  bool uploadStarted = false;
  String created_at= "";

  String? _date;

  Future getDate() async {
    DateTime now = DateTime.now();
    String _d = DateFormat('dd MMMM yy').format(now);
    setState(() {
      _date = _d;
    });
  }

  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (ab.userType == 'tester') {
        openDialog(context, 'You are a Tester',
            'Only Admin can upload, delete & modify contents');
      } else {
        setState(() => uploadStarted = true);
        await updateDatabase();
        setState(() => uploadStarted = false);
        openDialog(context, 'Updated Successfully', '');
      }
    }
  }

  String setImg(String type, String oldImgFile, Uint8List? fileBytes, String waktu){

      if(oldImgFile.length > 0){
          // FirebaseStorage.instance.refFromURL(oldImgFile).delete();

          if(fileBytes != null){
              FirebaseStorage.instance
                .ref()
                .child("files/$waktu-$type")
                .putData(fileBytes!);

                return Constants.logPath + "$waktu-$type?alt=media";
          }

      } 

       return oldImgFile;

  }

  Future updateDatabase() async {
    final DocumentReference ref = firestore.collection('product').doc(widget.productData.timestamp);
    String waktu = widget.productData.timestamp.toString();

    String thumb = setImg("thumbnail", oldThumbnailName, thumbnail,waktu);
    String im1 = setImg("img1", oldImg1Name, img1, waktu);
    String im2 = setImg("img2", oldImg2Name, img2, waktu);

    var _productData = {
      'productName': productNameCtrl.text,
      'productDetail': productDetailCtrl.text,
      'phone': sellerContact.text,
      'price': priceCtrl.text,
      'image-1': thumb,
      'image-2': im1,
      'image-3': im2,
      'status': statusSelection,
      'updated_at': _date,
    };
    await ref.update(_productData);
  }

  clearTextFeilds() {
    productNameCtrl.clear();
    productDetailCtrl.clear();
    sellerContact.clear();
    priceCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  handlePreview() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await showProductPreview(
          context,
          productNameCtrl.text,
          productDetailCtrl.text,
          oldThumbnailName,
          sellerContact.text,
          statusSelection,
          created_at,
          priceCtrl.text);
    }
  }

  initBlogData() {
    ProductModel d = widget.productData;
    productNameCtrl.text = d.productName!;
    productDetailCtrl.text = d.productDetails!;
    sellerContact.text = d.phone!;
    priceCtrl.text = d.price!;
    oldThumbnailName = d.image1!;
    oldImg1Name = d.image2!;
    oldImg2Name = d.image3!;
    statusSelection = d.status!;
    created_at = d.created_at!;
  }

  @override
  void initState() {
    super.initState();
    initBlogData();
  }

  FilePickerResult? ImgSecure(FilePickerResult? thumbnailResult, String typeImg){
    if (thumbnailResult != null) {

      String extension = thumbnailResult.files.first.extension.toString(); 

      if(thumbnailResult.files.first.size > 1200000){
        openDialog(context, typeImg, "");
      } else {

        return thumbnailResult;
        // if(extension == "jpg" || extension == "jpeg" || extension == "png"){
        // } else {
        //   openDialog(context, "File Type Doesn`t Allowed", "");
        // }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    getDate();

    return Scaffold(
        appBar: AppBar(),
        key: scaffoldKey,
        backgroundColor: Colors.grey[200],
        body: CoverWidget(
          widget: Form(
              key: formKey,
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: h * 0.10,
                  ),
                  Text(
                    'Update Product Details',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  statusDropdown(),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: inputDecoration(
                        'Enter Product Name', 'Product Name', productNameCtrl),
                    controller: productNameCtrl,
                    validator: (value) {
                      if (value!.isEmpty) return 'Value is empty';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: inputDecoration(
                        'Enter Phone Number', 'Phone', sellerContact),
                    controller: sellerContact,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Value is empty';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: inputDecoration(
                        'Enter Price', 'Price', priceCtrl),
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Value is empty';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: CustomCacheImage(
                        imageUrl: oldThumbnailName, radius: 0.0)
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    style: buttonStyleIMG(Colors.grey[200]),
                    onPressed: () async {
                    FilePickerResult? successSecure = ImgSecure(await FilePicker.platform.pickFiles(type: FileType.image), "Thumbnail Image Too Large");

                      if (successSecure != null) {
                        thumbnail = successSecure.files.first.bytes;
                      }

                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Upload Thumnail (Image 1)", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: CustomCacheImage(
                        imageUrl: oldImg1Name, radius: 0.0)
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    style: buttonStyleIMG(Colors.grey[200]),
                    onPressed: () async {
                      FilePickerResult? successSecure = ImgSecure(await FilePicker.platform.pickFiles(type: FileType.image), "Second Image Too Large");

                      if (successSecure != null) {
                        img1 = successSecure.files.first.bytes;
                      }

                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Upload Image 2", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: CustomCacheImage(
                        imageUrl: oldImg2Name, radius: 0.0)
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    style: buttonStyleIMG(Colors.grey[200]),
                    onPressed: () async {
                        FilePickerResult? successSecure = ImgSecure(await FilePicker.platform.pickFiles(type: FileType.image), "Third Image Too Large");

                        if (successSecure != null) {
                          img2 = successSecure.files.first.bytes;
                        }

                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Upload Image 3", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Enter Description (Html or Normal Text)',
                        border: OutlineInputBorder(),
                        labelText: 'Product Description',
                        contentPadding: EdgeInsets.only(
                            right: 0, left: 10, top: 15, bottom: 5),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey[300],
                            child: IconButton(
                                icon: Icon(Icons.close, size: 15),
                                onPressed: () {
                                  productDetailCtrl.clear();
                                }),
                          ),
                        )),
                    textAlignVertical: TextAlignVertical.top,
                    minLines: 5,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: productDetailCtrl,
                    validator: (value) {
                      if (value!.isEmpty) return 'Value is empty';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton.icon(
                          icon: Icon(
                            Icons.remove_red_eye,
                            size: 25,
                            color: Colors.blueAccent,
                          ),
                          label: Text(
                            'Preview',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          onPressed: () {
                            handlePreview();
                          })
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      color: Colors.deepPurpleAccent,
                      height: 45,
                      child: uploadStarted == true
                          ? Center(
                              child: Container(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator()),
                            )
                          : TextButton(
                              child: Text(
                                'Update Product',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () async {
                                handleSubmit();
                              })),
                  SizedBox(
                    height: 200,
                  ),
                ],
              )),
        ));
  }

  Widget statusDropdown() {
    // final AdminBloc ab = Provider.of(context, listen: false);

    List<String> ab = ["Terjual", "Belum Terjual"];

    return Container(
        height: 50,
        padding: EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            decoration: InputDecoration(border: InputBorder.none),
            onChanged: (dynamic value) {
              setState(() {
                statusSelection = value;
              });
            },
            onSaved: (dynamic value) {
              setState(() {
                statusSelection = value;
              });
            },
            value: statusSelection,
            hint: Text('Select Status'),
            items: ab.map((f) {
              return DropdownMenuItem(
                child: Text(f),
                value: f,
              );
            }).toList()));
  }
}
