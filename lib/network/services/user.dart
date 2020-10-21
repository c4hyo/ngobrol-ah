import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserServices {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static CollectionReference users =
      FirebaseFirestore.instance.collection("users");

  static Future<User> signup(
      {String nama, String email, String password}) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user.updateProfile(
        displayName: nama,
      );

      await users.doc(userCredential.user.uid).set({
        "nama": nama,
        "telepon": null,
        "foto_profil": null,
        "bio": null,
      });
      return userCredential.user;
    } catch (e) {
      return e;
    }
  }

  static Future<User> signIn({String email, String password}) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      return e;
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<void> changePassword({String password, User user}) async {
    try {
      await user.updatePassword(password);
      return await auth.signOut();
    } catch (e) {
      return e;
    }
  }

  static Stream<User> get checkUser => auth.authStateChanges();

  static Future<DocumentSnapshot> getProfil(String id) async {
    try {
      return await users.doc(id).get();
    } catch (e) {
      return e;
    }
  }
}
