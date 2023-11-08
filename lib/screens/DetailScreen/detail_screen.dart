// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'components/detail_screen_body.dart';

class DetailScreen extends StatelessWidget {
  final String imageUrl;
  final String imageId;
  Wallpaper wallpaper;
  final bool isNSFW;

  DetailScreen({
    Key? key,
    required this.imageUrl,
    required this.wallpaper,
    this.isNSFW = false,
    this.imageId = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailScreenBody(
          imageUrl: imageUrl,
          wallpaper: wallpaper,
          imageId: imageId,
          isNSFW: isNSFW),
    );
  }
}
