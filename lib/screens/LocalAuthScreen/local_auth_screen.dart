import 'package:flutter/material.dart';
import 'components/local_auth_screen_body.dart';

class LocalAuthScreen extends StatelessWidget {
  const LocalAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LocalAuthScreenBody(),
    );
  }
}
