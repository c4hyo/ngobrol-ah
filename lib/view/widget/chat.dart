import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngobrol_ah/network/model/chat_model.dart';
import 'package:ngobrol_ah/utilities/text.dart';
import 'package:ngobrol_ah/view/screen/home/chat_room.dart';
import 'package:ngobrol_ah/view/screen/home/image_view.dart';

class Bub extends StatelessWidget {
  const Bub({
    @required ScrollController scrollController,
    @required this.widget,
    this.snapshot,
  }) : _scrollController = scrollController;

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
                            width: MediaQuery.of(context).size.width * (3 / 5),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  ImageView(
                                    imageUrl: dekripsi(
                                      Encrypted.fromBase64(chat.pesan),
                                    ),
                                  ),
                                );
                              },
                              child: Image(
                                image: NetworkImage(
                                  dekripsi(
                                    Encrypted.fromBase64(chat.pesan),
                                  ),
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : Text(
                            dekripsi(
                              Encrypted.fromBase64(chat.pesan),
                            ),
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
                            width: MediaQuery.of(context).size.width * (3 / 5),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  ImageView(
                                    imageUrl: dekripsi(
                                      Encrypted.fromBase64(chat.pesan),
                                    ),
                                  ),
                                );
                              },
                              child: Image(
                                image: NetworkImage(
                                  dekripsi(
                                    Encrypted.fromBase64(chat.pesan),
                                  ),
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : Text(
                            dekripsi(
                              Encrypted.fromBase64(chat.pesan),
                            ),
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
