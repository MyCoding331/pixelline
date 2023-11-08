import 'package:flutter/material.dart';
import 'package:pixelline/screens/CommonScreen/common_screen.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'package:pixelline/util/util.dart';

class TagsCard extends StatelessWidget {
  const TagsCard({
    super.key,
    required this.tags,
  });

  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    String formatTitle(String title) {
      String newTitle = title
          .replaceAll('-wallpapers', '')
          .replaceAll('-', ' ')
          .replaceAll(',', '')
          .capitalize();
      return newTitle;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: tags.map((tag) {
          final newTag =
              tag.id.replaceAll('-wallpapers', '').replaceAll('/', '');
          final newTitle = formatTitle(tag.title);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CommonScreen(passedData: 'wall/$newTag'),
                ),
              );
            },
            child: Chip(
              label: Text(
                newTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.black54,
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
