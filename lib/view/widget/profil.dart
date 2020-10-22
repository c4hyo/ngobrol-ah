import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/view/screen/user/edit_profil.dart';

Widget profil(BuildContext context, {UserModel model, User user}) {
  return Column(
    children: [
      Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(100, 50),
            bottomRight: Radius.elliptical(100, 50),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              top: 10,
              left: 10,
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  maxRadius: 80,
                  backgroundImage:
                      (model.fotoProfil == null || model.fotoProfil == "")
                          ? AssetImage("asset/logo.png")
                          : NetworkImage(model.fotoProfil),
                ),
              ),
            )
          ],
        ),
      ),
      ListTile(
        title: Text(
          "Nama",
          style: TextStyle(fontSize: 18),
        ),
        subtitle: Text(
          model.nama,
          style: TextStyle(fontSize: 18),
        ),
      ),
      (user.uid != model.uid)
          ? SizedBox.shrink()
          : ListTile(
              title: Text(
                "Email",
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                user.email,
                style: TextStyle(fontSize: 18),
              ),
            ),
      ListTile(
        title: Text(
          "Telepon",
          style: TextStyle(fontSize: 18),
        ),
        subtitle: Text(
          model.telepon,
          style: TextStyle(fontSize: 18),
        ),
      ),
      ListTile(
        title: Text(
          "Bio",
          style: TextStyle(fontSize: 18),
        ),
        subtitle: Text(
          model.bio,
          style: TextStyle(fontSize: 18),
        ),
      ),
      (user.uid != model.uid)
          ? SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: MaterialButton(
                child: Text(
                  "Ubah Profil",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () {
                  Get.to(
                    UserEditProfil(
                      user: user,
                      userModel: model,
                    ),
                  );
                },
                minWidth: double.infinity,
                height: 60,
                color: Theme.of(context).primaryColor,
              ),
            )
    ],
  );
}
