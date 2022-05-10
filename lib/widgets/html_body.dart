import 'package:admin/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

  // final String demoText = "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s</p>" + 
  // //'''<iframe width="560" height="315" src="https://www.youtube.com/embed/-WRzl9L4z3g" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'''+
  // '''<video controls src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"></video>''' + 
  // "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s</p>";

class HtmlBodyWidget extends StatelessWidget {
  const HtmlBodyWidget({Key? key, required this.htmlDescription}) : super(key: key);

  final String htmlDescription;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: '''$htmlDescription''',
      onLinkTap: (String? url, RenderContext context1,Map<String, String> attributes, _) {
        AppService().openLink(context, url!);
      },
      onImageTap: (String? url, RenderContext context1,Map<String, String> attributes, _) {
        AppService().openLink(context, url!);
      },
      style: {
        "body": Style(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            fontSize: FontSize(17.0),
            fontWeight: FontWeight.normal,
            fontFamily: '',
            color: Colors.grey[700]),

        "figure": Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),

        //Disable this line to disable full width picture/video support
        //"p,h1,h2,h3,h4,h5,h6": Style(margin: EdgeInsets.all(20)),
      },
    );
  }
}