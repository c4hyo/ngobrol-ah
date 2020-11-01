import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';

class UserServices {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static CollectionReference users =
      FirebaseFirestore.instance.collection("users");

  static Future<User> signup(
      {String nama, String email, String password, String token}) async {
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
        "token": token,
      });
      return userCredential.user;
    } catch (e) {
      return e;
    }
  }

  static Future<User> signIn(
      {String email, String password, String token}) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      isOnline(
        user: userCredential.user,
        isOnline: true,
      );
      await users.doc(userCredential.user.uid).set(
        {
          "token": token,
        },
        SetOptions(
          merge: true,
        ),
      );

      return userCredential.user;
    } catch (e) {
      return e;
    }
  }

  static Future<void> signOut({User user}) async {
    isOnline(isOnline: false, user: user);
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

  static Future<void> isOnline({User user, bool isOnline}) async {
    return await users.doc(user.uid).set(
      {
        "isOnline": isOnline,
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> isWriting({User user, bool isWriting}) async {
    return await users.doc(user.uid).set(
      {
        "isWriting": isWriting,
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> updateProfil({UserModel userModel, User user}) async {
    try {
      await user.updateProfile(
        displayName: userModel.nama,
      );
      return await users.doc(user.uid).set(
        {
          "nama": userModel.nama,
          "telepon": userModel.telepon,
          "foto_profil": userModel.fotoProfil,
          "bio": userModel.bio,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      return e;
    }
  }
}
