import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:ngobrol_ah/utilities/text.dart';
import 'package:uuid/uuid.dart';

class ChatServices {
  static CollectionReference chats =
      FirebaseFirestore.instance.collection("chat-room");
  static FirebaseMessaging fcm = FirebaseMessaging();

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
      "pesan": enkripsi(message).base64,
      "type": type,
      "is_read": false,
      // "dibuat": DateFormat('yyyy-MM-dd hh:mm:aa').format(DateTime.now()),
      "dibuat": DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>> sendAndReterive(
      {String pesan, String pengirim, String token}) async {
    String serverToken =
        "AAAAJ35EKPI:APA91bFbR_e30w4vS3CxchZyO_Jw76SlSEd9aLcAuST876oFBv-tu7PG31G3UyQA35PxywGo6bU7j8lr-r6Lfe9pNBcdGSWoAsUdf2fD8d-WE23o-_O7OjncPxzWcDzfG88nSqBqdCaa";
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': pesan,
            'title': pengirim,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': Uuid().v4(),
            'status': 'done'
          },
          'to': token,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }

  static Future<Map<String, dynamic>> sendImageAndReterive(
      {String pesan, String pengirim, String token}) async {
    String serverToken =
        "AAAAJ35EKPI:APA91bFbR_e30w4vS3CxchZyO_Jw76SlSEd9aLcAuST876oFBv-tu7PG31G3UyQA35PxywGo6bU7j8lr-r6Lfe9pNBcdGSWoAsUdf2fD8d-WE23o-_O7OjncPxzWcDzfG88nSqBqdCaa";
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'image': pesan,
            'body': "pesan baru",
            'title': pengirim,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': Uuid().v4(),
            'status': 'done'
          },
          'to': token,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }
}
