import 'package:flutter/material.dart';
import 'components/common_screen_body.dart';

class CommonScreen extends StatelessWidget {
  final String passedData;

  const CommonScreen({super.key, required this.passedData});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonScreenBody(
        passedData: passedData,
      ),
    );
  }
}
