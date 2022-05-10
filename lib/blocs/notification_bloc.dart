import 'dart:convert';
import 'package:admin/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:admin/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationBloc extends ChangeNotifier {
  

  Future sendNotification (String title) async{
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Config().serverToken}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Click here to read more details',
            'title': title,
            'sound':'default'
          },
          'priority': 'normal',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': "/topics/${Constants.fcmSubscriptionTopic}",
        },
      ),
    );
  }



  Future saveToDatabase(String? timestamp, String title, String description) async {
    final DocumentReference ref = FirebaseFirestore.instance.collection('notifications').doc(timestamp);
    await ref.set({
      'title': title,
      'description': description,
      'created_at': DateTime.now(),
      'timestamp': timestamp,
    });
  }




}
