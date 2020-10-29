import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ngobrol_ah/network/model/chat_model.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/network/services/chat.dart';
import 'package:ngobrol_ah/utilities/storage.dart';
import 'package:ngobrol_ah/utilities/text.dart';
import 'package:ngobrol_ah/view/screen/home/image_view.dart';
import 'package:ngobrol_ah/view/screen/user/profil.dart';

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
        chatRoom: widget.roomId,
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
        title: ListTile(
          onTap: () {
            Get.to(
              ProfilScreen(
                user: widget.user,
                userModel: widget.userModelOther,
              ),
            );
          },
          title: Text(
            widget.userModelOther.nama,
            style: TextStyle(color: Colors.white),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: (widget.userModelOther.fotoProfil == null ||
                    widget.userModelOther.fotoProfil == "")
                ? AssetImage("asset/logo.png")
                : NetworkImage(widget.userModelOther.fotoProfil),
          ),
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

class Bub extends StatelessWidget {
  const Bub({
    Key key,
    @required ScrollController scrollController,
    @required this.widget,
    this.snapshot,
  })  : _scrollController = scrollController,
        super(key: key);

  final ScrollController _scrollController;
  final ChatRoom widget;
  final AsyncSnapshot<QuerySnapshot> snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      itemCount: snapshot.data.docs.length,
      itemBuilder: (context, index) {
        DocumentSnapshot docs = snapshot.data.docs[index];
        ChatModel chat = ChatModel.toMaps(docs);
        return (chat.userId == widget.user.uid)
            ? Bubble(
                margin: BubbleEdges.only(top: 10),
                alignment: Alignment.topRight,
                nipWidth: 8,
                nipHeight: 24,
                nip: BubbleNip.rightTop,
                color: Color.fromRGBO(225, 255, 199, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    (chat.type == "image")
                        ? Container(
                            height: 200,
                            width: 200,
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  ImageView(
                                    imageUrl: chat.pesan,
                                  ),
                                );
                              },
                              child: Image(
                                image: NetworkImage(chat.pesan),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : Text(
                            chat.pesan,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.right,
                          ),
                    Text(
                      timeAgo(tanggal: chat.dibuat),
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              )
            : Bubble(
                margin: BubbleEdges.only(top: 10),
                alignment: Alignment.topLeft,
                nipWidth: 8,
                nipHeight: 24,
                nip: BubbleNip.leftTop,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (chat.type == "image")
                        ? Container(
                            height: 200,
                            width: 200,
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  ImageView(
                                    imageUrl: chat.pesan,
                                  ),
                                );
                              },
                              child: Image(
                                image: NetworkImage(chat.pesan),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : Text(
                            chat.pesan,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.right,
                          ),
                    Text(
                      timeAgo(
                        tanggal: chat.dibuat,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              );
      },
    );
  }
}
