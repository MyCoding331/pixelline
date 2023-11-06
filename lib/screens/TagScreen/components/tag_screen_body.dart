// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/screens/CommonScreen/common_screen.dart';
import 'package:pixelline/services/wallpaper.dart';
import 'package:http/http.dart' as http;
import 'package:pixelline/util/util.dart';

class TagScreenBody extends StatefulWidget {
  String param;
  TagScreenBody({super.key, required this.param});

  @override
  State<TagScreenBody> createState() => _TagScreenBodyState();
}

class _TagScreenBodyState extends State<TagScreenBody> {
  List<Tag> tags = [];

  @override
  void initState() {
    super.initState();
    fetchTags();
  }

  Future<void> fetchTags() async {
    try {
      final response = await http.get(
          Uri.parse('https://hqwalls.vercel.app/api/detail${widget.param}'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> tagsData = data['tags'];
        setState(() {
          tags = tagsData.map((tagData) => Tag.fromJson(tagData)).toList();
        });
      } else {
        // Handle error response
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle network or parsing error
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Replace this with your API call or data retrieval logic for tags

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text(
            'Tags :',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: tags.map((tag) {
              final newTag =
                  tag.id.replaceAll('-wallpapers', '').replaceAll('/', '');
              final newTitle = tag.title
                  .replaceAll('-wallpapers', '')
                  .replaceAll('-', ' ')
                  .replaceAll(',', '')
                  .capitalize();
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
