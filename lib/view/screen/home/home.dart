import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/network/services/chat.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:ngobrol_ah/utilities/text.dart';
import 'package:ngobrol_ah/view/screen/home/chat_room.dart';
import 'package:ngobrol_ah/view/screen/home/user_all.dart';
import 'package:ngobrol_ah/view/screen/user/profil.dart';

class Home extends StatefulWidget {
  final User user;
  final UserModel userModel;
  const Home({Key key, this.user, this.userModel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String idUser, lastPesan;
  FirebaseMessaging fcm = FirebaseMessaging();

  @override
  void initState() {
    // fcm.getToken().then((value) => print(value.toString()));
    fcm.configure();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: UserServices.users.doc(widget.user.uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return UserAccountsDrawerHeader(
                    accountName: Text(widget.userModel.nama),
                    accountEmail: Text(widget.user.email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: (widget.userModel.fotoProfil == null ||
                              widget.userModel.fotoProfil == "")
                          ? AssetImage("asset/logo.png")
                          : NetworkImage(widget.userModel.fotoProfil),
                    ),
                  );
                }
                DocumentSnapshot docs = snapshot.data;
                UserModel model = UserModel.toMaps(docs);
                return UserAccountsDrawerHeader(
                  accountName: Text(model.nama),
                  accountEmail: Text(widget.user.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        (model.fotoProfil == null || model.fotoProfil == "")
                            ? AssetImage("asset/logo.png")
                            : NetworkImage(model.fotoProfil),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Profil"),
              leading: Icon(Icons.person_outline),
              onTap: () {
                Get.back();
                Get.to(
                  ProfilScreen(
                    user: widget.user,
                    userModel: widget.userModel,
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Ganti Password"),
              leading: Icon(Icons.lock_outline),
            ),
            Expanded(child: SizedBox.shrink()),
            ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.exit_to_app),
              onTap: () async {
                await UserServices.signOut();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Ngobrol Kuy",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              .orderBy("created_at", descending: true)
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
                        onTap: () async {
                          Get.to(
                            ChatRoom(
                              roomId: data.id,
                              user: widget.user,
                              userModel: widget.userModel,
                              userModelOther: model,
                            ),
                            transition: Transition.rightToLeft,
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
                            return Row(
                              children: [
                                (_pesan['user_id'] == widget.user.uid)
                                    ? Icon(Icons.arrow_left)
                                    : Icon(Icons.arrow_right),
                                (_pesan['type'] == "image")
                                    ? Text("Gambar")
                                    : Text(_pesan['pesan']),
                              ],
                            );
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
