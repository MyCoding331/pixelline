import 'package:flutter/material.dart';
import 'components/categorie_screen_body.dart';

class CategorieScreen extends StatelessWidget {
  const CategorieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CategorieScreenBody(),
    );
  }
}
