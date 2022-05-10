import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/models/place.dart';
import 'package:admin/pages/comments.dart';
import 'package:admin/pages/update_place.dart';
import 'package:admin/utils/cached_image.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/empty.dart';
import 'package:admin/utils/next_screen.dart';
import 'package:admin/utils/styles.dart';
import 'package:admin/utils/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({Key? key}) : super(key: key);

  @override
  _PlacesPageState createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage>{


  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController? controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _snap = [];
  List<Place> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String collectionName = 'places';

  late bool _descending;
  late String _orderBy;
  String? _sortByText;
  bool? _hasData;

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _sortByText = 'Newest First';
    _orderBy = 'timestamp';
    _descending = true;
    if(this.mounted){
      _getData();
    }
  }



  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null)
      data = await firestore
          .collection(collectionName)
          .orderBy(_orderBy, descending: _descending)
          .limit(10)
          .get();
    else
      data = await firestore
          .collection(collectionName)
          .orderBy(_orderBy, descending: _descending)
          .startAfter([_lastVisible![_orderBy]])
          .limit(10)
          .get();

    if (data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasData = true;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => Place.fromFirestore(e)).toList();
        });
      }
    } else {
      if(_lastVisible == null){
        setState(() {
          _isLoading = false;
          _hasData = false; 
        });
      }else{
        setState(() {
          _isLoading = false;
          _hasData = true;
        });
        openToast(context, 'No more content available');
        
      }
    }
    return null;
  }


  refreshData () {
    setState(() {
      _isLoading = true;
      _snap.clear();
      _data.clear();
      _lastVisible = null;
    });
    _getData();
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

  navigateToReviewPage(context, timestamp, name) {
    nextScreenPopuup(context, CommentsPage(collectionName: collectionName, timestamp: timestamp, title: name,));
  }



  handleDelete(timestamp) {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
          contentPadding: EdgeInsets.all(50),
          elevation: 0,
          children: <Widget>[
            Text('Delete?',

                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            SizedBox(
              height: 10,
            ),
            Text('Want to delete this item from the database?',

                style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Row(
                children: <Widget>[
                TextButton(
                style: buttonStyle(Colors.redAccent),
                child: Text(
                  'Yes',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: ()async{
                  
                  if (ab.userType == 'tester') {
                    Navigator.pop(context);
                    openDialog(context, 'You are a Tester', 'Only admin can delete contents');
                  } else {
                    await ab.deleteContent(timestamp, collectionName)
                    .then((value) => ab.removefromFeaturedList(context, timestamp))
                    .then((value) => ab.decreaseCount('places_count'));
                    refreshData();
                    Navigator.pop(context);
                    

                  }
                },
              ),

              SizedBox(width: 10),

              TextButton(
                style: buttonStyle(Colors.deepPurpleAccent),
                child: Text(
                  'No',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.pop(context),
              ),
                ],
              )
            )
          ],
        );

    });
  }



  




  openFeaturedDialog (String? timestamp) {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              Text('Add to Featured',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              SizedBox(
                height: 10,
              ),
              Text('Do you Want to add this item to the featured list?',
                  style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  TextButton(
                    style: buttonStyle(Colors.redAccent),
                    child: Text(
                      'Yes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      if (ab.userType == 'tester') {
                        Navigator.pop(context);
                        openDialog(context, 'You are a Tester', 'Only admin can do this');
                      } else {

                        await context.read<AdminBloc>().getFeaturedList().then((List featuredList)async{
                          if(featuredList.length <= 10){
                            await context.read<AdminBloc>().addToFeaturedList(context, timestamp);
                            Navigator.pop(context);
                          }else{
                            Navigator.pop(context);
                            openDialog(context, 'Fetured items are greater than 10 contents!', 'The limit of featured item is 10. Please remove some items from featured contents and try again');
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    style: buttonStyle(Colors.deepPurpleAccent),
                    child: Text(
                      'No',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ))
            ],
          );
        });
  }




  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Places',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            sortingPopup()
          ],
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
          ? EmptyPage(icon: Icons.content_paste, message: 'No data available.\nUpload first!')
          : RefreshIndicator(

            child: ListView.builder(
              padding: EdgeInsets.only(top: 30, bottom: 20),
              controller: controller,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: _data.length + 1,
              itemBuilder: (_, int index) {
                if (index < _data.length) {
                  return dataList(_data[index]);
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
              
                refreshData();
              
            },
          ),
        ),
      ],
    );
  }

 
 
 
 
  Widget dataList(Place d) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(top: 5, bottom: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: <Widget>[
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),),
            child: CustomCacheImage(imageUrl: d.imageUrl1, radius: 10,),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(
                //top: 15,
                left: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        d.name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(LineIcons.mapMarker, size: 15, color: Colors.grey),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        d.location!,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.access_time, size: 15, color: Colors.grey),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        d.date!,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: 35,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.grey,
                            ),
                            Text(
                              d.loves.toString(),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        child: Container(
                        height: 35,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.comment,
                              size: 16,
                              color: Colors.grey[800],
                            ),
                            Text(
                              d.commentsCount.toString(),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            )
                          ],
                        ),
                      ),
                        onTap: () {
                          navigateToReviewPage(context, d.timestamp, d.name);
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      
                      InkWell(
                        child: Container(
                            height: 35,
                            width: 45,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.edit,
                                size: 16, color: Colors.grey[800])),
                        onTap: () {
                          nextScreen(context, UpdatePlace(placeData: d));
                        },
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        child: Container(
                            height: 35,
                            width: 45,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.delete,
                                size: 16, color: Colors.grey[800])),
                        onTap: () {
                          handleDelete(d.timestamp);
                        },
                      ),

                      SizedBox(width: 10),

                      Container(
                        height: 35,
                        padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextButton.icon(
                            onPressed: () => openFeaturedDialog(d.timestamp),
                            icon: Icon(LineIcons.plus),
                            label: Text('Add to Featured')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }




  Widget sortingPopup (){
    return PopupMenuButton(
      child: Container(
              height: 40,
              padding: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(30)),
              child : Row(children: [
                Icon(CupertinoIcons.sort_down, color: Colors.grey[800],),
                SizedBox(width: 10,),
              Text('Sort By - $_sortByText', style: TextStyle(
                color: Colors.grey[900],
                fontWeight: FontWeight.w500
              ),)
              ],),),
      itemBuilder: (BuildContext context){
        return <PopupMenuItem>[
          PopupMenuItem(
            child: Text('Newest First'),
            value: 'new',
          ),
          PopupMenuItem(
            child: Text('Oldest First'),
            value: 'old',
          ),
          PopupMenuItem(
            child: Text('Most Popular'),
            value: 'popular',
          ),
          PopupMenuItem(
            child: Text('Most Commented'),
            value: 'comments',
          ),
        ];
      },
      onSelected: (dynamic value){
        if(value == 'new'){
          setState(() {
            _sortByText = 'Newest First';
            _orderBy = 'timestamp';
            _descending = true;
          });
        }else if(value == 'old'){
          setState(() {
            _sortByText = 'Oldest First';
            _orderBy = 'timestamp';
            _descending = false;
          });
        }else if(value == 'popular'){
          setState(() {
            _sortByText = 'Most Popular';
            _orderBy = 'loves';
            _descending = true;
          });
        }else if(value == 'comments'){
          setState(() {
            _sortByText = 'Most Commented';
            _orderBy = 'comments count';
            _descending = true;
          });
        }
        refreshData();
      },
    );
  }


}


