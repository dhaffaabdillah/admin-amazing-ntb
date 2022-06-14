import 'dart:typed_data';

import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/constants/constants.dart';
import 'package:admin/models/blog.dart';
import 'package:admin/models/categori.dart';
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

class UpdateCategori extends StatefulWidget {
  final CategoriesModel categoriData;
  UpdateCategori({Key? key, required this.categoriData}) : super(key: key);

  @override
  _UpdateCategoriState createState() => _UpdateCategoriState();
}

class _UpdateCategoriState extends State<UpdateCategori> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

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

  Future updateDatabase() async {
    final DocumentReference ref = firestore.collection('categories').doc(widget.categoriData.timestamp);

    var _categorisData = {
       'title': titleCtrl.text.toLowerCase(),
       'updated_at': _date,
    };

    await ref.update(_categorisData);
  }

  clearTextFeilds() {
    titleCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  initBlogData() {
    CategoriesModel d = widget.categoriData;
    titleCtrl.text = d.title!;
    created_at = d.created_at!;
  }

  @override
  void initState() {
    super.initState();
    initBlogData();
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
                    'Update Category Details',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: inputDecoration(
                        'Enter Category Name', 'Category Name', titleCtrl),
                    controller: titleCtrl,
                    validator: (value) {
                      if (value!.isEmpty) return 'Value is empty';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
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
                                'Update Category',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () async {
                                handleSubmit();
                              }
                            )
                          ),
                  SizedBox(
                    height: 200,
                  ),
                ],
              )),
        ));
  }

}
