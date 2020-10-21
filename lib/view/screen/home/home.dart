import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/network/services/chat.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:ngobrol_ah/utilities/text.dart';
import 'package:ngobrol_ah/view/screen/home/chat_room.dart';
import 'package:ngobrol_ah/view/screen/home/user_all.dart';

class Home extends StatefulWidget {
  final User user;
  final UserModel userModel;
  const Home({Key key, this.user, this.userModel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String idUser, lastPesan;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await UserServices.signOut();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.chat_bubble_outline),
        onPressed: () {
          Get.to(
            UserAllScreen(
              user: widget.user,
              userModel: widget.userModel,
            ),
            fullscreenDialog: true,
          );
        },
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: ChatServices.chats
              .where("member", arrayContains: widget.userModel.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot data = snapshot.data.docs[index];
                Map<String, dynamic> _member = data.data();
                List _members = _member['member'];
                _members.forEach((element) {
                  if (element != widget.user.uid) {
                    idUser = element;
                  }
                });
                return StreamBuilder<DocumentSnapshot>(
                  stream: UserServices.users.doc(idUser).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Card(
                        child: Text(""),
                      );
                    }
                    UserModel model = UserModel.toMaps(snapshot.data);
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Get.to(
                            ChatRoom(
                              roomId: data.id,
                              user: widget.user,
                              userModel: widget.userModel,
                              userModelOther: model,
                            ),
                          );
                        },
                        title: Text(model.nama),
                        subtitle: StreamBuilder<QuerySnapshot>(
                          stream: ChatServices.chats
                              .doc(data.id)
                              .collection("pesan")
                              .orderBy("dibuat", descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context, s) {
                            if (!s.hasData) {
                              return Text("");
                            }
                            DocumentSnapshot dsc = s.data.docs.last;
                            Map<String, dynamic> _pesan = dsc.data();
                            lastPesan = _pesan['dibuat'];
                            return Text(_pesan['pesan']);
                          },
                        ),
                        trailing: StreamBuilder<QuerySnapshot>(
                          stream: ChatServices.chats
                              .doc(data.id)
                              .collection("pesan")
                              .orderBy("dibuat", descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context, s) {
                            if (!s.hasData) {
                              return Text("");
                            }
                            DocumentSnapshot dsc = s.data.docs.last;
                            Map<String, dynamic> _pesan = dsc.data();
                            lastPesan = _pesan['dibuat'];
                            return Text(timeAgo(tanggal: lastPesan));
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
