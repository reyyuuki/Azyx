import 'package:flutter/material.dart';

class Stream extends StatefulWidget {
  final String id;
  const Stream({super.key, required this.id});

  @override
  State<Stream> createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      title: Text("Streaming"),
    ),);
  }
}