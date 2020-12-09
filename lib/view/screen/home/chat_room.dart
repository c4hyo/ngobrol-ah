import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/network/services/chat.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:ngobrol_ah/utilities/storage.dart';
import 'package:ngobrol_ah/view/screen/user/profil.dart';
import 'package:ngobrol_ah/view/widget/chat.dart';

class ChatRoom extends StatefulWidget {
  final String roomId;
  final User user;
  final UserModel userModel;
  final UserModel userModelOther;

  ChatRoom({this.user, this.userModel, this.userModelOther, this.roomId});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  int _chat = 0;
  int _chats = 0;
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  String _message;
  File _foto;
  ScrollController _scrollController = new ScrollController();
  ImagePicker _picker = new ImagePicker();

  _handleImage() async {
    final imageFile = await _picker.getImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _foto = File(imageFile.path);
      });
      _message = await StorageService.uploadUserPhotoImage(
        "",
        _foto,
        category: "chat",
      );
      await ChatServices.sendMessage(
        type: "image",
        chatRoom: (_chat > 0 && _chats == 0)
            ? widget.roomId
            : widget.userModelOther.uid + "-" + widget.userModel.uid,
        message: _message,
        model: widget.userModel,
        model2: widget.userModelOther,
      );
      await ChatServices.sendImageAndReterive(
        pengirim: widget.userModel.nama,
        pesan: _message,
        token: widget.userModelOther.token,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: (widget.userModelOther.fotoProfil == null ||
                    widget.userModelOther.fotoProfil == "")
                ? AssetImage("asset/logo.png")
                : NetworkImage(widget.userModelOther.fotoProfil),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Get.back(),
          )
        ],
        title: StreamBuilder<DocumentSnapshot>(
          stream: UserServices.users.doc(widget.userModelOther.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return ListTile(
                onTap: () {
                  Get.to(
                    ProfilScreen(
                      user: widget.user,
                      userModel: widget.userModelOther,
                    ),
                  );
                },
                leading: Icon(
                  Icons.circle,
                  color: (widget.userModelOther.isOnline)
                      ? Colors.white
                      : Colors.red,
                ),
                title: Text(
                  widget.userModelOther.nama,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            DocumentSnapshot docs = snapshot.data;
            UserModel model = UserModel.toMaps(docs);
            return model.isWriting
                ? ListTile(
                    onTap: () {
                      Get.to(
                        ProfilScreen(
                          user: widget.user,
                          userModel: model,
                        ),
                      );
                    },
                    leading: Icon(
                      Icons.circle,
                      color: (model.isOnline) ? Colors.white : Colors.red,
                    ),
                    title: Text(
                      model.nama,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "Sedang Menulis",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListTile(
                    onTap: () {
                      Get.to(
                        ProfilScreen(
                          user: widget.user,
                          userModel: model,
                        ),
                      );
                    },
                    leading: Icon(
                      Icons.circle,
                      color: (model.isOnline) ? Colors.white : Colors.red,
                    ),
                    title: Text(
                      model.nama,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: ChatServices.chats
                      .doc(widget.roomId)
                      .collection("pesan")
                      .orderBy("dibuat", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    _chat = snapshot.data.docs.length;
                    return (snapshot.data.docs.length > 0)
                        ? Bub(
                            scrollController: _scrollController,
                            widget: widget,
                            snapshot: snapshot,
                          )
                        : StreamBuilder(
                            stream: ChatServices.chats
                                .doc(widget.userModelOther.uid +
                                    "-" +
                                    widget.userModel.uid)
                                .collection("pesan")
                                .orderBy("dibuat", descending: true)
                                .snapshots(),
                            builder: (context, snaps) {
                              if (!snaps.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              _chats = snaps.data.docs.length;
                              return (snaps.data.docs.length > 0)
                                  ? Bub(
                                      scrollController: _scrollController,
                                      widget: widget,
                                      snapshot: snaps,
                                    )
                                  : Center(
                                      child: Text("Obrolan baru"),
                                    );
                            },
                          );
                  },
                ),
              ),
            ),
            Container(
              height: 60,
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                    ),
                    onPressed: _handleImage,
                  ),
                  Expanded(
                    child: Form(
                      key: _form,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              await UserServices.isWriting(
                                isWriting: false,
                                user: widget.user,
                              );
                              // print("tidak menulis");
                            } else {
                              await UserServices.isWriting(
                                isWriting: true,
                                user: widget.user,
                              );
                              // print("sedang menulis");
                            }
                          },
                          onSaved: (newValue) {
                            _message = newValue;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await UserServices.isWriting(
                        isWriting: false,
                        user: widget.user,
                      );
                      FocusScope.of(context).unfocus();
                      if (_form.currentState.validate()) {
                        _form.currentState.save();
                        _form.currentState.reset();
                        await ChatServices.sendMessage(
                          type: "text",
                          chatRoom: (_chat > 0 && _chats == 0)
                              ? widget.roomId
                              : widget.userModelOther.uid +
                                  "-" +
                                  widget.userModel.uid,
                          message: _message,
                          model: widget.userModel,
                          model2: widget.userModelOther,
                        );
                        await ChatServices.sendAndReterive(
                          pengirim: widget.userModel.nama,
                          pesan: _message,
                          token: widget.userModelOther.token,
                        );
                      }
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
