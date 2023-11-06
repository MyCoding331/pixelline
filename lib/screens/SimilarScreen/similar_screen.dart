// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'components/similar_screen_body.dart';

class SimilarScreen extends StatelessWidget {
  String param;
  SimilarScreen({super.key, required this.param});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimilarScreenBody(
        param: param,
      ),
    );
  }
}
