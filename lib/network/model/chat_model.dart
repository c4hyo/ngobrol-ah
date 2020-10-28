import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String dari;
  String dibuat;
  String pesan;
  String type;
  String userId;

  ChatModel({
    this.dari,
    this.dibuat,
    this.pesan,
    this.type,
    this.userId,
  });
  factory ChatModel.toMaps(DocumentSnapshot doc) {
    return ChatModel(
      dari: doc.data()['dari'] ?? "",
      dibuat: doc.data()['dibuat'] ?? "",
      pesan: doc.data()['pesan'] ?? "",
      type: doc.data()['type'],
      userId: doc.data()['user_id'] ?? "",
    );
  }
}
