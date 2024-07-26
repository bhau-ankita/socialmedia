import 'package:flutter/material.dart';

class Commentsheet extends StatefulWidget {
  const Commentsheet(
      {super.key, required void Function(String comment) addComment});

  @override
  State<Commentsheet> createState() => _CommentsheetState();
}

class _CommentsheetState extends State<Commentsheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
