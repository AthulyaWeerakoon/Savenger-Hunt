import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scavenger_s_hunt/session.dart';
import 'package:scavenger_s_hunt/main.dart';

class PuzzlePage extends StatefulWidget {
  final SessionConnection session;
  final int quizInt;

  const PuzzlePage({super.key, required this.session, required this.quizInt});

  @override
  State<PuzzlePage> createState() => _PuzzlePage();
}



class _PuzzlePage extends State<PuzzlePage> {
  late StreamSubscription subscription;
  String attributes = "";
  final List<bool> isLoaded = List.from([false, false, false, false]);
  final List<File> tivaFiles = List.from([null, null, null, null]);
  late String quizTitle;

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
              sock.write('N${widget.quizInt}:P');
              subscription = sock.listen((buffer) {
                recv = String.fromCharCodes(buffer).trim();
                print(recv);
                if(recv == 'EP'){
                  // toast Internal error, attempted to retreive a puzzle that does not exist
                  Navigator.pop(context);
                }
                else if(recv == 'EI'){
                  // toast Internal error, has skipped signup process, restart and try again
                  Navigator.pop(context);
                }
                else if(recv.startsWith('P')){
                  List<String> qnNAttr = recv.substring(1).split(":");
                  if(int.parse(qnNAttr[0]) == widget.quizInt) attributes = qnNAttr[1];
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

  Future<bool> loadLocal() async {
    String path = await widget.session.localPath;
    final qpath = "$path/Q${widget.quizInt}/";
    if(attributes.contains('T')){
      var textPath = "${qpath}text.txt";
      if(await Link(textPath).exists()){
        tivaFiles[0] = File(textPath);
        setState(() {
          isLoaded[0] = true;
        });
      }
    }
    if(attributes.contains('I')){
      var imagePath = "${qpath}image.png";
      if(await Link(imagePath).exists()){
        tivaFiles[1] = File(imagePath);
        setState(() {
          isLoaded[1] = true;
        });
      }
    }
    if(attributes.contains('V')){
      var videoPath = "${qpath}video.wmv";
      if(await Link(videoPath).exists()){
        tivaFiles[2] = File(videoPath);
        setState(() {
          isLoaded[2] = true;
        });
      }
    }
    if(attributes.contains('A')){
      var audioPath = "${qpath}audio.mp3";
      if(await Link(audioPath).exists()){
        tivaFiles[3] = File(audioPath);
        setState(() {
          isLoaded[3] = true;
        });
      }
    }

    return false;
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