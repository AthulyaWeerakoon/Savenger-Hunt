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

  Future<String> get localPath async {
    Directory directory = await getApplicationDocumentsDirectory();
    
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await localPath;
    return File('$path/user_data.txt');
  }

  Future<List<String>> get _fileData async {
    final file = await _localFile;
    try{
      final contents = await file.readAsString();

      return contents.split(' ');
    } catch(e) {
      file.writeAsString(
        'mail: key: lastQ: totalQ: '
        );
      return _fileData;
    }
  }

  Future<String> readKey() async {
    final data = await _fileData;
    final key = data[1].split(':')[1];

    if(key == '') { return '0'; }
    else { return key; }
  }

  Future<String> readMail() async {
    final data = await _fileData;
    final mail = data[0].split(':')[1];

    if(mail == '') { return '0'; }
    else { return mail; }
  }

  Future<bool> get _keyRetreieved async {
    final key = await readKey();
    if (key == '0') { return false; }
    else { return true; }
  }

  Future<List<String>> getMailKeyPair() async {
    return [await readMail(), await readKey()];
  }

  Future<File> setMailKeyPair(String mail, String key) async {
    final file = await _localFile;
    final contents = await file.readAsString();

    final int mailEndsAt = contents.indexOf(' ');
    final int keyEndsAt = contents.substring(mailEndsAt + 1).indexOf(' ') + mailEndsAt + 2;
    
    return await file.writeAsString("mail:$mail key:$key ${contents.substring(keyEndsAt)}");
  }

  Future<int> getLastQ() async {
    final file = await _localFile;
    final contents = await file.readAsString();

    final List<String> isolatedData = contents.split(' ');
    return int.parse(isolatedData[2].split(':')[1]);
  }

  Future<File> setLastQ(int lastQ) async {
    final file = await _localFile;
    final contents = await file.readAsString();
    print(contents);

    final List<String> splitString = contents.split('lastQ:');
    final String postQsplit = splitString[1].split(' ')[1];
    print("${splitString[0]}lastQ:$lastQ $postQsplit");

    return await file.writeAsString("${splitString[0]}lastQ:$lastQ $postQsplit");
  }

  Future<int> getTotalQ() async {
    final file = await _localFile;
    final contents = await file.readAsString();

    final List<String> isolatedData = contents.split(' ');
    return int.parse(isolatedData[3].split(':')[1]);
  }

  Future<File> setTotalQ(int totalQ) async {
    final file = await _localFile;
    final contents = await file.readAsString();
    print(contents);

    final List<String> splitString = contents.split('totalQ:');
    print("${splitString[0]}totalQ:$totalQ");

    return await file.writeAsString("${splitString[0]}totalQ:$totalQ");
  }

  Future<bool> getKeyRetreived() async {
    return await _keyRetreieved;
  }

  Future<SecureSocket> getSocket() => 
    Future.delayed(
      const Duration(seconds: 2),
      () => _sock,
    );
}
