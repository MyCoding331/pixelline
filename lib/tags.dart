// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pixelline/container_screen.dart';

class Tag {
  final String id;
  final String title;

  Tag({required this.id, required this.title});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(id: json['id'], title: json['title']);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class TagFetchingScreen extends StatefulWidget {
  String param;
  TagFetchingScreen({super.key, required this.param});

  @override
  _TagFetchingScreenState createState() => _TagFetchingScreenState();
}

class _TagFetchingScreenState extends State<TagFetchingScreen> {
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
      children: [
        const SizedBox(height: 70),
        Wrap(
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
                        ViewContainer(passedData: 'wall/$newTag'),
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
      ],
    );
  }
}
