// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:pixelline/global/appbar.dart';
import 'components/common_screen_body.dart';

class CommonScreen extends StatelessWidget {
  final String passedData;

  CommonScreen({super.key, required this.passedData});
  late String title = passedData.replaceAll("wall/", "");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(text: title),
      body: CommonScreenBody(
        passedData: passedData,
      ),
    );
  }
}
