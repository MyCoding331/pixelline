// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:pixelline/components/data.dart';
import 'package:pixelline/screens/CommonScreen/common_screen.dart';

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
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CommonScreen(passedData: 'wall/$link'),
                    ),
                  );
                  (BuildContext context) {
                    Navigator.pop(context, 'reload');
                  };
                },
                child: GridTile(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: Image.asset(
                          image,
                          fit: BoxFit.cover,
                          height: 150,
                          width: double.infinity,
                          // color: Colors.grey,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(6.0),
                          topLeft: Radius.circular(3.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          color: Colors.black,
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
