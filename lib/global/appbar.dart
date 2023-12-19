import 'package:flutter/material.dart';

AppBar appBar(
    {required String text,
    bool backButton = true,
    Widget? leading = const SizedBox.shrink()}) {
  return AppBar(
    automaticallyImplyLeading: backButton,
    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 30,
    ),
    shadowColor: Colors.transparent,
    leading: leading,
    title: Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: Colors.white,
  );
}
