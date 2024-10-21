import 'package:flutter/material.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  // UserModel user = new UserModel();
  // UserModel data = _auth.getUser();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("Feed"),
    );
  }
}
