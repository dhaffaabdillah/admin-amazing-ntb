import 'dart:typed_data';

import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/constants/constants.dart';
import 'package:admin/utils/cached_image.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/styles.dart';
import 'package:admin/widgets/product_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:universal_html/html.dart';

class UploadCategoris extends StatefulWidget {
  UploadCategoris({Key? key}) : super(key: key);

  @override
  _UploadCategorisState createState() => _UploadCategorisState();
}

class _UploadCategorisState extends State<UploadCategoris> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var titleCtrl = TextEditingController();

  bool notifyUsers = true;
  bool uploadStarted = false;
  String? _timestamp;
  String? _date;
  var _categorisData;

  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (ab.userType == 'tester') {
        openDialog(context, 'You are a Tester',
            'Only Admin can upload, delete & modify contents');
      } else {
        setState(() => uploadStarted = true);
        await getDate().then((_) async {
          await saveToDatabase().then((value) =>
              context.read<AdminBloc>().increaseCount('categories_count'));
          setState(() => uploadStarted = false);
          openDialog(context, 'Uploaded Successfully', '');
          clearTextFeilds();
        });
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
        firestore.collection('categories').doc(_timestamp);

      _categorisData = {
        'title': titleCtrl.text.toLowerCase(),
        'created_at': _date,
        'updated_at': _date,
        'timestamp': _timestamp
      };
      await ref.set(_categorisData);
  }

  clearTextFeilds() {
    titleCtrl.clear();
    FocusScope.of(context).unfocus();
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
                'Category Details',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration:
                    inputDecoration('Enter Category name', 'Category name', titleCtrl),
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
                            'Upload Category',
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
    );
  }
  
}
