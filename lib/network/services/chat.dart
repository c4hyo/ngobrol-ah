import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';

class ChatServices {
  static CollectionReference chats =
      FirebaseFirestore.instance.collection("chat-room");

  static Future<void> addChatRoom({UserModel user1, UserModel user2}) async {
    return await chats.add({
      "isGroup": false,
      "memberId": [
        user1.uid,
        user2.uid,
      ],
      "namaMember": [
        user1.nama,
        user2.nama,
      ],
    });
  }

  static Future<void> sendMessage({
    String chatRoom,
    String message,
    UserModel model,
    UserModel model2,
    String type,
  }) async {
    await chats.doc(chatRoom).set({
      "created_at": DateTime.now(),
      "member": [
        model.uid,
        model2.uid,
      ]
    });
    return await chats.doc(chatRoom).collection("pesan").add({
      "dari": model.nama,
      "user_id": model.uid,
      "pesan": message,
      "type": type,
      // "dibuat": DateFormat('yyyy-MM-dd hh:mm:aa').format(DateTime.now()),
      "dibuat": DateTime.now().toIso8601String(),
    });
  }
}
