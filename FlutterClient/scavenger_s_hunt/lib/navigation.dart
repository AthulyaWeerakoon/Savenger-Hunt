import 'package:flutter/material.dart';
import 'package:scavenger_s_hunt/session.dart';

class NavigationPage extends StatefulWidget {
  final SessionConnection session;

  const NavigationPage({super.key, required this.session});

  @override
  State<NavigationPage> createState() => _NavigationPage();
}



class _NavigationPage extends State<NavigationPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/ui/nav_test_img.png",
          width: 200,
        ),
      ),
    );
  }
}