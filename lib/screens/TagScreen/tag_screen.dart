// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'components/tag_screen_body.dart';

class TagScreen extends StatelessWidget {
  String param;
  TagScreen({super.key, required this.param});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TagScreenBody(
        param: param,
      ),
    );
  }
}
