import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/styles.dart';
import 'package:admin/widgets/blog_preview.dart';
import 'package:admin/widgets/product_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UploadProducts extends StatefulWidget {
  UploadProducts({Key? key}) : super(key: key);

  @override
  _UploadProductsState createState() => _UploadProductsState();
}

class _UploadProductsState extends State<UploadProducts> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();

  var productNameCtrl = TextEditingController();
  var productDetailCtrl = TextEditingController();
  var sellerContact = TextEditingController();
  var image1Ctrl = TextEditingController();
  var image2Ctrl = TextEditingController();
  var image3Ctrl = TextEditingController();

  var statusSelection;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  bool notifyUsers = true;
  bool uploadStarted = false;
  String? _timestamp;
  String? _date;
  var _productData;

  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);

    if (statusSelection == null) {
      openDialog(context, 'Select Status Please', '');
    } else {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        if (ab.userType == 'tester') {
          openDialog(context, 'You are a Tester',
              'Only Admin can upload, delete & modify contents');
        } else {
          setState(() => uploadStarted = true);
          await getDate().then((_) async {
            await saveToDatabase().then((value) =>
                context.read<AdminBloc>().increaseCount('blogs_count'));
            setState(() => uploadStarted = false);
            openDialog(context, 'Uploaded Successfully', '');
            clearTextFeilds();
          });
        }
      }
    }
  }

  Future getDate() async {
    DateTime now = DateTime.now();
    String _d = DateFormat('dd MMMM yy').format(now);
    String _t = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      _timestamp = _t;
      _date = _d;
    });
  }

  Future saveToDatabase() async {
    final DocumentReference ref =
        firestore.collection('product').doc(_timestamp);
    _productData = {
      'productName': productNameCtrl.text,
      'productDetail': productDetailCtrl.text,
      'phone': sellerContact.text,
      'image-1': image1Ctrl.text,
      'image-2': image2Ctrl.text,
      'image-3': image3Ctrl.text,
      'status': statusSelection,
      'created_at': _timestamp,
      'updated_at': _timestamp
    };
    await ref.set(_productData);
  }

  clearTextFeilds() {
    productNameCtrl.clear();
    productDetailCtrl.clear();
    sellerContact.clear();
    image1Ctrl.clear();
    image2Ctrl.clear();
    image3Ctrl.clear();
    FocusScope.of(context).unfocus();
  }

  handlePreview() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await getDate().then((_) async {
        await showProductPreview(
            context,
            productNameCtrl.text,
            productDetailCtrl.text,
            image1Ctrl.text,
            sellerContact.text,
            statusSelection,
            'Now');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      body: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: h * 0.10,
              ),
              Text(
                'Product Details',
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
                decoration: inputDecoration('Enter image url (thumbnail)',
                    'Image1(Thumbnail)', image1Ctrl),
                controller: image1Ctrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration:
                    inputDecoration('Enter image url', 'Image2', image2Ctrl),
                controller: image2Ctrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration:
                    inputDecoration('Enter image url', 'Image3', image3Ctrl),
                controller: image3Ctrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Enter Description (Html or Normal Text)',
                    border: OutlineInputBorder(),
                    labelText: 'Product Description',
                    contentPadding:
                        EdgeInsets.only(right: 0, left: 10, top: 15, bottom: 5),
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
                            fontWeight: FontWeight.w400, color: Colors.black),
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
                            'Upload Product',
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
    );
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
