import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String nama;
  String telepon;
  String uid;
  String fotoProfil;
  String bio;
  String token;

  UserModel({
    this.nama,
    this.telepon,
    this.uid,
    this.fotoProfil,
    this.bio,
    this.token,
  });

  factory UserModel.toMaps(DocumentSnapshot doc) {
    return UserModel(
      fotoProfil: doc.data()['foto_profil'] ?? "",
      nama: doc.data()['nama'] ?? "",
      telepon: doc.data()['telepon'] ?? "",
      uid: doc.id,
      bio: doc.data()['bio'] ?? "",
      token: doc.data()['token'] ?? "",
    );
  }
}
