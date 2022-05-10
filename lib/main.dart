import 'package:admin/pages/home.dart';
import 'package:admin/pages/sign_in.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'blocs/admin_bloc.dart';
import 'blocs/notification_bloc.dart';
import 'blocs/comment_bloc.dart';

void main(){
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<AdminBloc>(create: (context) => AdminBloc()),
      ChangeNotifierProvider<CommentBloc>(create: (context) => CommentBloc()),
      ChangeNotifierProvider<NotificationBloc>(create: (context) => NotificationBloc())

    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: TouchAndMouseScrollBehavior(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.grey[900],fontWeight: FontWeight.w600, fontSize: 18
          ),
          elevation: 0,
          
          actionsIconTheme: IconThemeData(
            color: Colors.grey[900],
          ),
          iconTheme: IconThemeData(
            color: Colors.grey[900]
          )
        ),
        
      ),
      home: MyApp1(),
    ),
    
    
    
    
    
    );
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ab = context.watch<AdminBloc>();
    return ab.isSignedIn == false ? SignInPage() : HomePage();
  }
}


class TouchAndMouseScrollBehavior extends MaterialScrollBehavior {
    // Override behavior methods and getters like dragDevices
    @override
    Set<PointerDeviceKind> get dragDevices => { 
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      // etc.
    };
}