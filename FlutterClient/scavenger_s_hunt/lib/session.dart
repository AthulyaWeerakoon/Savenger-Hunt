import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SessionConnection {
  final SecurityContext _context = SecurityContext(withTrustedRoots: true);
  late SecureSocket _sock;

  SessionConnection() {
    _context.setTrustedCertificates('assets/cert/cert.pem');
    //try{
    SecureSocket.connect('127.0.0.1', 443, timeout: const Duration(seconds: 1, milliseconds: 500), context: _context,
    onBadCertificate: (X509Certificate c){
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

  Future<SecureSocket> getSocket() => 
    Future.delayed(
      const Duration(seconds: 2),
      () => _sock,
    );
}
