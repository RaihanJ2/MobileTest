// ignore_for_file: prefer_const_constructors, must_be_immutable, use_key_in_widget_constructors

import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/screens/auth_screen.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:chatapp/screens/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Navbar extends StatefulWidget {
  UserModel user;
  Navbar(this.user);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            accountName: Text(""),
            accountEmail: Text(user.email!),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
          ),
          ListTile(
              leading: Icon(Icons.chat_outlined),
              title: Text('Chat'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(widget.user),
                    ),
                    (route) => false);
              }),
          ListTile(
              leading: Icon(Icons.search_outlined),
              title: Text('Search'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(widget.user),
                    ),
                    (route) => false);
              }),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Logout'),
            onTap: () async {
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(),
                  ),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
