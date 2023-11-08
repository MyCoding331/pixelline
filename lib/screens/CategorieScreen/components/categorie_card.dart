import 'package:flutter/material.dart';
import 'package:pixelline/screens/CommonScreen/common_screen.dart';

class CategorieCard extends StatelessWidget {
  final dynamic link;
  final dynamic image;
  final dynamic name;
  const CategorieCard({
    super.key,
    required this.link,
    required this.image,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommonScreen(passedData: 'wall/$link'),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
  }
}
