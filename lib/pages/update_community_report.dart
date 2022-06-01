import 'dart:typed_data';

import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/constants/constants.dart';
import 'package:admin/models/blog.dart';
import 'package:admin/models/community_report.dart';
import 'package:admin/models/product.dart';
import 'package:admin/utils/cached_image.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/styles.dart';
import 'package:admin/widgets/community_report_preview.dart';
import 'package:admin/widgets/product_preview.dart';
import 'package:admin/widgets/cover_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateCommunityReport extends StatefulWidget {
  final CommunityReportModel CommunityReportData;
  UpdateCommunityReport({Key? key, required this.CommunityReportData}) : super(key: key);

  @override
  _UpdateCommunityReportState createState() => _UpdateCommunityReportState();
}

class _UpdateCommunityReportState extends State<UpdateCommunityReport> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();

  var report_title = TextEditingController();
  var report_desc = TextEditingController();
  var institution = TextEditingController();

  String? image_1, image_2, image_3;

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

  Future updateDatabase() async {
    final DocumentReference ref = firestore.collection('community_report').doc(widget.CommunityReportData.timestamp);
    String waktu = widget.CommunityReportData.timestamp.toString();

    var _productData = {
      'institution': institution,
      'status': statusSelection,
      'updated_at': _date,
    };
    await ref.update(_productData);
  }

  clearTextFeilds() {
    institution.clear();
    FocusScope.of(context).unfocus();
  }

  handlePreview() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await showCommunityReportPreview(
          context,
          report_title.text,
          report_desc.text,
          image_1,
          institution.text,
          statusSelection,
          created_at,);
    }
  }

  initBlogData() {
    CommunityReportModel d = widget.CommunityReportData;
    report_title.text = d.report_title!;
    report_desc.text = d.report_desc!;
    institution.text = d.institution!;
    image_1 = d.image1!;
    image_2 = d.image2!;
    image_2 = d.image3!;
    statusSelection = d.status!;
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
                    'Community Report Details',
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
                        'Report Title', 'Report Title', report_title),
                    controller: report_title,
                    enabled: false,
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
                        'Institution', 'Institution', institution),
                    controller: institution,
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
                        imageUrl: image_1, radius: 0.0)
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: CustomCacheImage(
                        imageUrl: image_2, radius: 0.0)
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: CustomCacheImage(
                        imageUrl: image_3, radius: 0.0)
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                        hintText: 'Enter Description (Html or Normal Text)',
                        border: OutlineInputBorder(),
                        labelText: 'Community Report Description',
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
                                  report_desc.clear();
                                }),
                          ),
                        )),
                    textAlignVertical: TextAlignVertical.top,
                    minLines: 5,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: report_desc,
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
                                'Update Community',
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

    List<String> ab = ["Belum Di Review", "Sudah Di Review", "Proses Pengerjaan"];

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
