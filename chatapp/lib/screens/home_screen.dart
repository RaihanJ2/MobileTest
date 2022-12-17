// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/widgets/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  UserModel user;
  HomeScreen(this.user);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Navbar(widget.user),
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[400],
        ),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.user.uid)
                .collection('message')
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.docs.length < 1) {
                  return Center(
                    child: Text('No Chat Available'),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      var friendId = snapshot.data.docs[index].id;
                      var lastMsg = snapshot.data.docs[index]['last_msg'];

                      return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(friendId)
                              .get(),
                          builder: (context, AsyncSnapshot asyncSnapshot) {
                            if (asyncSnapshot.hasData) {
                              var friend = asyncSnapshot.data;
                              return Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            width: 0.5, color: Colors.black),
                                        bottom: BorderSide(
                                            width: 0.5, color: Colors.black))),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: CachedNetworkImage(
                                      imageUrl: friend['image'],
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      height: 50,
                                    ),
                                  ),
                                  title: Text(
                                    friend['name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto'),
                                  ),
                                  subtitle: Container(
                                    child: Text(
                                      "$lastMsg",
                                      style: TextStyle(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) => ChatScreen(
                                                currentUser: widget.user,
                                                friendId: friend['uid'],
                                                friendName: friend['name'],
                                                friendImage:
                                                    friend['image']))));
                                  },
                                ),
                              );
                            }
                            return LinearProgressIndicator();
                          });
                    });
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
