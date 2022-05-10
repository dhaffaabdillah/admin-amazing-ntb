import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


void openToast(context, message){
  Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.BOTTOM,
    textColor: Colors.white,
    
    
  );
}