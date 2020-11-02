import 'package:jiffy/jiffy.dart';
import 'package:encrypt/encrypt.dart';

String timeAgo({String tanggal}) {
  return Jiffy(tanggal).fromNow();
}

Encrypted enkripsi(String text) {
  final key = Key.fromUtf8('81657fbaaec67dc15e73585c92e923c6');
  final iv = IV.fromLength(16);
  final enc = Encrypter(AES(key));
  return enc.encrypt(text, iv: iv);
}

String dekripsi(Encrypted text) {
  final key = Key.fromUtf8('81657fbaaec67dc15e73585c92e923c6');
  final iv = IV.fromLength(16);
  final enc = Encrypter(AES(key));
  return enc.decrypt(text, iv: iv);
}
