import 'package:scavenger_s_hunt/signup.dart';
import 'package:scavenger_s_hunt/session.dart';
import 'package:scavenger_s_hunt/first.dart';
import 'package:scavenger_s_hunt/navigation.dart';

import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scavenger\'s App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        useMaterial3: true,
      ),
      home: FirstPage(
        session: SessionConnection(),
      ),
    );
  }
}

Route routeFirstToSignup(SessionConnection session) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SignupPage(session: session),
    transitionsBuilder: (context, animation, secondaryAnimation, child){
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route routeToNavigation(SessionConnection session) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => NavigationPage(session: session),
    transitionsBuilder: (context, animation, secondaryAnimation, child){
      return child;
    },
  );
}