// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:pixelline/components/Data/data.dart';
import 'package:pixelline/screens/CategorieScreen/components/categorie_card.dart';

class CategorieScreenBody extends StatelessWidget {
  const CategorieScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
            // child: SizedBox(
            //   height: 70,
            // ),
            ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            mainAxisExtent: 150,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = imageData[index];
              final name = item['title'];
              final image = item['image'];
              final link = name.replaceAll(" ", "-").toLowerCase();
              return CategorieCard(
                link: link,
                image: image,
                name: name,
              );
            },
            childCount: imageData.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80), // Add some whitespace at the end
        ),
      ],
    ));
  }
}
