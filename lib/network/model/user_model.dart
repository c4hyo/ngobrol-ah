import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String nama;
  String telepon;
  String uid;
  String fotoProfil;
  String bio;
  String token;
  bool isOnline;
  bool isWriting;

  UserModel({
    this.nama,
    this.telepon,
    this.uid,
    this.fotoProfil,
    this.bio,
    this.token,
    this.isOnline,
    this.isWriting,
  });

  factory UserModel.toMaps(DocumentSnapshot doc) {
    return UserModel(
      fotoProfil: doc.data()['foto_profil'] ?? "",
      nama: doc.data()['nama'] ?? "",
      telepon: doc.data()['telepon'] ?? "",
      uid: doc.id,
      bio: doc.data()['bio'] ?? "",
      token: doc.data()['token'] ?? "",
      isOnline: doc.data()['isOnline'] ?? false,
      isWriting: doc.data()['isWriting'] ?? false,
    );
  }
}
