import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:ngobrol_ah/view/screen/home/chat_room.dart';
import 'package:uuid/uuid.dart';

class UserAllScreen extends StatelessWidget {
  final User user;
  final UserModel userModel;

  const UserAllScreen({Key key, this.user, this.userModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pilih User"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: UserServices.users.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                UserModel model = UserModel.toMaps(snapshot.data.docs[index]);
                return (model.uid != userModel.uid)
                    ? Card(
                        child: ListTile(
                          onTap: () async {
                            Get.back();
                            Get.to(
                              ChatRoom(
                                roomId: Uuid().v1(),
                                user: user,
                                userModel: userModel,
                                userModelOther: model,
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            maxRadius: 25,
                            backgroundColor: Colors.transparent,
                            backgroundImage: (model.fotoProfil == "" ||
                                    model.fotoProfil == null)
                                ? AssetImage("asset/logo.png")
                                : NetworkImage(model.fotoProfil),
                          ),
                          title: Text(
                            model.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(model.bio),
                        ),
                      )
                    : SizedBox();
              },
            );
          },
        ),
      ),
    );
  }
}
