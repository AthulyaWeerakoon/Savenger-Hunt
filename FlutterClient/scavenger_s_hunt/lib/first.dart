import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scavenger_s_hunt/session.dart';
import 'package:scavenger_s_hunt/main.dart';

class FirstPage extends StatefulWidget {
  final SessionConnection session;

  const FirstPage({super.key, required this.session});

  @override
  State<FirstPage> createState() => _SignupPage();
}



class _SignupPage extends State<FirstPage> {
  late StreamSubscription subscription;

  void toSignup(bool forcedWait) {
    if(forcedWait){
      Future.delayed(const Duration(seconds: 3));
    }
    Navigator.of(context).push(routeFirstToSignup(widget.session));
  }

  void toNavigation() {
    Navigator.of(context).push(routeToNavigation(widget.session));
  }

  @override
  void initState() {

    widget.session.getKeyRetreived().then((bool value){
      if (!value){
        Future.delayed(const Duration(seconds: 3));
        Navigator.of(context).push(routeFirstToSignup(widget.session));
      }
      else {
        String recv = "";

        widget.session.getSocket().then(
          (SecureSocket sock) {
          widget.session.getMailKeyPair().then(
            (List<String> pair) {
              sock.write('L${pair[0]}:${pair[1]}');
              subscription = sock.listen((buffer) {
                recv = String.fromCharCodes(buffer).trim();
                print(recv);
                if(recv == 'EN'){
                  // toast Invalid email address
                  toSignup(true);
                }
                else if(recv == 'ET'){
                  // toast Invalid token: try to regenerate key by signing out
                  toSignup(true);
                }
                else if(recv == 'E1'){
                  // toast Another device has already connected to this session
                  exit(0);
                }
                else if(recv.startsWith('SL')){
                  // toask Logged in successfully
                  widget.session.setLastQ(int.parse(recv.split(":")[1]));
                  Navigator.of(context).push(routeToNavigation(widget.session));
                }
                else{
                  
                }
              });
            },
            onError: (error){
              print(error);
            }
          );
          },
          onError: (error){
            print(error);
          }
        );
      }
    });

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
          "assets/ui/startup_img.png",
          height: 100,
          width: 100,
        ),
      ),
    );
  }
}