import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:ngobrol_ah/view/widget/profil.dart';

class ProfilScreen extends StatefulWidget {
  final User user;
  final UserModel userModel;

  const ProfilScreen({Key key, this.user, this.userModel}) : super(key: key);
  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder<DocumentSnapshot>(
            stream: UserServices.users.doc(widget.user.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return profil(
                  context,
                  model: widget.userModel,
                  user: widget.user,
                );
              }
              DocumentSnapshot docs = snapshot.data;
              UserModel model = UserModel.toMaps(docs);
              return profil(
                context,
                model: model,
                user: widget.user,
              );
            },
          ),
        ),
      ),
    );
  }
}
