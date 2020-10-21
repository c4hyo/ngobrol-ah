import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/network/services/chat.dart';
import 'package:ngobrol_ah/utilities/text.dart';

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
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  String _message;
  ScrollController _scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userModelOther.nama),
        elevation: 0,
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
                    return ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot docs = snapshot.data.docs[index];
                        Map<String, dynamic> pesan = docs.data();
                        return (pesan['user_id'] == widget.user.uid)
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
                                    Text(
                                      pesan['pesan'],
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    Text(
                                      timeAgo(tanggal: pesan['dibuat']),
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
                                    Text(
                                      pesan['pesan'],
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    Text(
                                      timeAgo(tanggal: pesan['dibuat']),
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
                  },
                ),
              ),
            ),
            Container(
              height: 75,
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Form(
                      key: _form,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextFormField(
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
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_form.currentState.validate()) {
                        _form.currentState.save();
                        print(_message);
                        await ChatServices.sendMessage(
                          chatRoom: widget.roomId,
                          message: _message,
                          model: widget.userModel,
                          model2: widget.userModelOther,
                        );
                        _form.currentState.reset();
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
