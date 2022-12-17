// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/widgets/message_textfield.dart';
import 'package:chatapp/widgets/single_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:chatapp/models/user_model.dart';

class ChatScreen extends StatelessWidget {
  final UserModel currentUser;
  final String friendId;
  final String friendName;
  final String friendImage;

  ChatScreen({
    required this.currentUser,
    required this.friendId,
    required this.friendName,
    required this.friendImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: CachedNetworkImage(
                imageUrl: friendImage,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                height: 40,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              friendName,
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[400],
              ),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .collection('message')
                      .doc(friendId)
                      .collection('chats')
                      .orderBy("date", descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length < 1) {
                        return Center(
                          child: Text(
                            'There is no message yet.',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          reverse: true,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            bool isMe = snapshot.data.docs[index]['senderId'] ==
                                currentUser.uid;
                            return SingleMessage(
                                message: snapshot.data.docs[index]['message'],
                                isMe: isMe);
                          });
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            ),
          ),
          MessageTextField(currentUser.uid, friendId)
        ],
      ),
    );
  }
}
