import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class SessionConnection{
  final SecurityContext _context = SecurityContext(withTrustedRoots: true);
  late SecureSocket _sock;
  late String _key;

  SessionConnection() {
    _context.setTrustedCertificates('assets/cert/cert.pem');
    //try{
    SecureSocket.connect('127.0.0.1', 443, context: _context, onBadCertificate: (X509Certificate c){
    print("Certificate WARNING: ${c.issuer}:${c.subject}");
    return true;
    }).then((SecureSocket ss) => _sock = ss)
    .catchError((e) {
      print("Error: failed connectiong to remote server");
      exit(0);
    });
      
    //} catch (err) {
      /*
      Fluttertoast.showToast(
        msg: "Couldn't connect to Scavenger hunt's listen server",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      */
      //print(err);
      //exit(0);
    //}
  }

  void setKey(String key){
    _key = key;
  }

  String getKey(){
    return _key;
  }

  Future<SecureSocket> getSocket() async {
    return await _sock;
  }
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
      home: SignupPage(
        session: SessionConnection(),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  final SessionConnection session;

  const SignupPage({super.key, required this.session});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<SignupPage> createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  TextEditingController email = TextEditingController();
  TextEditingController otp = TextEditingController();
  TextEditingController regMail = TextEditingController();
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
  // Widget listen() {}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 15.0, 50.0, 0),
                    child: TextFormField(
                      controller: email,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(249, 166, 145, 1),),
                        ),
                        focusColor: const Color.fromRGBO(249, 166, 145, 1),
                        label: RichText(
                          text: const TextSpan(
                            text: "Enter university email address",
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 15,
                              color: Color.fromARGB(127, 0, 0, 0),
                              decorationColor: Color.fromRGBO(249, 166, 145, 1),
                            )
                          )
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 15.0, 50.0, 0),
                    child: TextFormField(
                      controller: otp,
                      decoration: InputDecoration(
                        enabledBorder: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(249, 166, 145, 1),)
                        ),
                        focusColor: const Color.fromRGBO(249, 166, 145, 1),
                        label: RichText(
                          text: const TextSpan(
                            text: "Enter OTP code",
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 15,
                              color: Color.fromARGB(127, 0, 0, 0),
                            )
                          )
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 25.0, 30.0, 0.0),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          constraints: const BoxConstraints(minWidth: 400.0, minHeight: 200, maxHeight: 300),
                          builder: (BuildContext context) {
                            return SizedBox(
                              width: 400,
                              height: 400,
                              child: Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const Text("Welcome to the hunt, Scavenger",
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                      ),
                                    ),
                                    const Text("Enter your university email address",
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                      ),
                                    ),
                                    Padding(padding: const EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 0.0),
                                      child: TextFormField(
                                        controller: regMail,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          label: Center(
                                            child: Text("Enter your email",
                                              style: TextStyle(
                                                fontFamily: 'Arial',
                                                fontSize: 15,
                                                color: Color.fromARGB(127, 0, 0, 0),
                                              ),
                                            ),
                                          )
                                        ),
                                      ),
                                    ),
                                    Padding(padding: const EdgeInsets.all(25.0),
                                      child:ElevatedButton(
                                        onPressed: () { },
                                        child: const Text(
                                          'Renew OTP',
                                          style: TextStyle(
                                            color: Color.fromRGBO(185, 105, 85, 1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ),
                            );
                          }
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "Haven't registered yet? Tap ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: 'Arial',
                              )
                            ),
                            TextSpan(
                              text: "here",
                              style: TextStyle(
                                color: Color.fromRGBO(249, 166, 145, 1),
                                fontFamily: 'Arial',
                                decoration: TextDecoration.underline,
                                decorationColor: Color.fromRGBO(249, 166, 145, 1),
                                decorationStyle: TextDecorationStyle.solid,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              )
                            ),
                            TextSpan(
                              text: " to register :)",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: 'Arial',
                              )
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            ),
            Container(
              width: 42,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(width: 0.0, color: Color.fromARGB(255, 253, 224, 217))
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Image.asset(
                    'assets/ui/reg_next.png',
                    height: 200,
                  )
                ],
              ),
            ),
            Container(
              width: 25,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 253, 224, 217),
                border: Border(
                  left: BorderSide(width: 0.0, color: Color.fromARGB(255, 253, 224, 217))
                )
              ),
            )
          ]
        ),
      ),
    );
  }
}