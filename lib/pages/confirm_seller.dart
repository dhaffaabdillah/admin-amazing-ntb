import 'package:admin/models/user.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/empty.dart';
import 'package:admin/utils/styles.dart';
import 'package:admin/utils/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmSellerPage extends StatefulWidget {
  const ConfirmSellerPage({Key? key}) : super(key: key);

  @override
  _ConfirmSellerPageState createState() => _ConfirmSellerPageState();
}

class _ConfirmSellerPageState extends State<ConfirmSellerPage> {


  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ScrollController? controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<DocumentSnapshot> _snap = [];
  List<User> _data = [];
  String collectionName = 'users';
  bool? _hasData;

  

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<Null> _getData() async {
    QuerySnapshot? data;
    if (_lastVisible == null)
      data = await firestore
          .collection(collectionName)
          .where("status_seller", isEqualTo: 2)
          // .orderBy('name', descending: false)
          .limit(15)
          .get();
    else
      data = await firestore
          .collection(collectionName)
          // .orderBy('name', descending: false)
          .where("status_seller", isEqualTo: 2)
          .startAfter([_lastVisible!['name']])
          .limit(15)
          .get();

    if (data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasData = true;
          _snap.addAll(data!.docs);
          _data = _snap.map((e) => User.fromFirestore(e)).toList();
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _hasData = false;
      });
      openToast(context, "No more users!");
    }
    return null;
  }



  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller!.position.pixels == controller!.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  Future updateDatabase(String uid) async {
    Navigator.pop(context);
    final DocumentReference ref = firestore.collection('users').doc(uid);
    var _usersData = {
      'status_seller': 1,
    };
    await ref.update(_usersData);
    openDialog(context, 'Updated Successfully', '');
  }

  void confirmDialog(context, title, message, String uid) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(50),
          elevation: 0,
          children: <Widget>[
            Text(title,
                
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            SizedBox(
              height: 10,
            ),
            Text(message,
                
                style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            SizedBox(
              height: 30,
            ),

              Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  style: buttonStyle(Colors.red),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                ),
                TextButton(
                  style: buttonStyle(Colors.deepPurpleAccent),
                  child: Text(
                    'Yes',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => {
                    updateDatabase(uid)
                  },
                ),
              ],
            )
          ],
        );
      });
}

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              'Confirmation Seller',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 10),
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  borderRadius: BorderRadius.circular(15)),
            ),
            Expanded(
              child: _hasData == false 
              ? EmptyPage(icon: Icons.content_paste, message: 'No users found!')
              : RefreshIndicator(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 20, bottom: 30),
                  controller: controller,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: _data.length + 1,
                  itemBuilder: (_, int index) {
                    if (index < _data.length) {
                      return _buildUserList(_data[index]);
                    }
                    return Center(
                      child: new Opacity(
                        opacity: _isLoading ? 1.0 : 0.0,
                        child: new SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: new CircularProgressIndicator()),
                      ),
                    );
                  },
                ),
                onRefresh: () async {
                  setState(() {
                      _data.clear();
                      _snap.clear();
                      _lastVisible = null;
                    });
                },
              ),
            ),
          ],
        );
  }

  Widget _buildUserList(User d) {
    return ListTile(
      leading : CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(d.imageUrl!),
      ),
      title: SelectableText(
        d.userName!,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: SelectableText('${d.userEmail} \nUID: ${d.uid}'),
      isThreeLine: true,
      trailing: InkWell(
        child: TextButton(
        style: buttonStyle(Colors.grey[200]),
        onPressed: () async {
          confirmDialog(context, "Apakah Anda Yakin?", "Apa anda yakin Ingin Merubah Status Menjadi Seller", d.uid.toString());
        },
        child: Text(
          "Confirmation",
          style: TextStyle(color: Colors.grey[900]),
        )),
      ),
    );
  }
}