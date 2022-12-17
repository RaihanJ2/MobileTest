// ignore_for_file: prefer_const_constructors, prefer_is_empty, must_be_immutable, use_key_in_widget_constructors, avoid_function_literals_in_foreach_calls

import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/widgets/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class SearchScreen extends StatefulWidget {
  UserModel user;
  SearchScreen(this.user);
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map> searchResult = [];
  bool isLoading = false;

  void onSearch() async {
    setState(() {
      searchResult = [];
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .where("name", isEqualTo: searchController.text)
        .get()
        .then((value) {
      if (value.docs.length < 1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("User is not Exist"),
        ));
        setState(() {
          isLoading = false;
        });
        return;
      }
      value.docs.forEach((user) {
        if (user.data()['email'] != widget.user.email) {
          searchResult.add(user.data());
        }
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Navbar(widget.user),
      appBar: AppBar(
        title: Text('Search'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                        hintText: "Username",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  onSearch();
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.teal,
                ),
              )
            ],
          ),
          if (searchResult.length != 0)
            Expanded(
                child: ListView.builder(
                    itemCount: searchResult.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Image.network(searchResult[index]['image']),
                        ),
                        title: Text(searchResult[index]['name']),
                        subtitle: Text(searchResult[index]['email']),
                        trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                searchController.text = "";
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => ChatScreen(
                                          currentUser: widget.user,
                                          friendId: searchResult[index]['uid'],
                                          friendName: searchResult[index]
                                              ['name'],
                                          friendImage: searchResult[index]
                                              ['image']))));
                            },
                            icon: Icon(Icons.message)),
                      );
                    }))
          else if (isLoading == true)
            Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
