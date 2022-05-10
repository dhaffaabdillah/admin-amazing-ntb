import 'package:flutter/material.dart';


class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key, required this.icon, required this.message}) : super(key: key);

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
        Icon(icon, size: 80, color: Colors.grey,),
        SizedBox(height: 10,),
        Text(message, style: TextStyle(fontSize: 20, color:Colors.grey, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)
      ],),
    );
  }
}