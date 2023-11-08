// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'components/card_screen_body.dart';

class CardScreen extends StatelessWidget {
  String? type;
  final List<Wallpaper> content;

  CardScreen({Key? key, required this.content, this.type = 'card'})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardScreenBody(
        type: type,
        content: content,
      ),
    );
  }
}
