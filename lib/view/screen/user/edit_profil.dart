import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';

class UserEditProfil extends StatefulWidget {
  final UserModel userModel;
  final User user;

  const UserEditProfil({Key key, this.userModel, this.user}) : super(key: key);
  @override
  _UserEditProfilState createState() => _UserEditProfilState();
}

class _UserEditProfilState extends State<UserEditProfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Mantap"),
    );
  }
}
