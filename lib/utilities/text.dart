import 'package:jiffy/jiffy.dart';

String timeAgo({String tanggal}) {
  return Jiffy(tanggal).fromNow();
}
