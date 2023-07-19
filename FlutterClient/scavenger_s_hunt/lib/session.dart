import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SessionConnection {
  final SecurityContext _context = SecurityContext(withTrustedRoots: true);
  late SecureSocket _sock;
  late String _key;

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

  Future<String> get _localPath async {
    Directory directory = await getApplicationDocumentsDirectory();
    
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user_data.txt');
  }

  Future<File> writeFile(String data) async {
    final file = await _localFile;

    return file.writeAsString(data);
  }

  Future<List<String>> get _fileData async {
    final file = await _localFile;
    try{
      final contents = await file.readAsString();

      return contents.split(' ');
    } catch(e) {
      file.writeAsString(
        'key: lastQ: '
        );
      return _fileData;
    }
  }

  Future<String> readKey() async {
    final data = await _fileData;
    final key = data[0].split(':')[1];

    if(key == '') { return '0'; }
    else { return key; }
  }

  Future<bool> get _dataRetreieved async {
    final key = await readKey();
    if (key == '0') { return false; }
    else { return true; }
  }

  void setKey(String key){
    _key = key;
  }

  String getKey(){
    return _key;
  }

  Future<bool> getDataRetreived() async {
    return await _dataRetreieved;
  }

  Future<SecureSocket> getSocket() => 
    Future.delayed(
      const Duration(seconds: 2),
      () => _sock,
    );
}
