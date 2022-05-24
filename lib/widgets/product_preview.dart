import 'package:admin/utils/cached_image.dart';
import 'package:admin/utils/currency_format.dart';
import 'package:admin/utils/styles.dart';
import 'package:admin/widgets/html_body.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Future showProductPreview(context, String? title, String? description,
    String? thumbnailUrl, String? Phone, String status, String? date, String? price) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.50,
            child: ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                        height: 350,
                        width: MediaQuery.of(context).size.width,
                        child: CustomCacheImage(
                            imageUrl: thumbnailUrl, radius: 0.0)
                        //Image(fit: BoxFit.cover, image: NetworkImage(thumbnailUrl)),
                        ),
                    Positioned(
                      top: 10,
                      right: 20,
                      child: CircleAvatar(
                        child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context)),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton(
                              style: buttonStyle(Colors.grey[200]),
                              onPressed: () async {
                                // await launch(status!);
                              },
                              child: Text(
                                status,
                                style: TextStyle(color: Colors.grey[900]),
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      Row(
                        children: <Widget>[
                          Text(
                            title.toString(),
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),

                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            height: 3,
                            width: 25,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(15)),
                          ),

                          Text(
                            CurrencyFormat.convertToIdr(int.parse(price.toString()), 0),
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),
                        ],
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 5, bottom: 10),
                        height: 3,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Phone.toString(),
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Icon(Icons.access_time, size: 16, color: Colors.grey),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              date!,
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      HtmlBodyWidget(htmlDescription: description!),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      });
}
