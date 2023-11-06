// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/services/api_service.dart';
import 'package:pixelline/services/wallpaper.dart';
import 'package:pixelline/screens/CardScreen/card_screen.dart';

class SimilarScreenBody extends StatefulWidget {
  String param;
  SimilarScreenBody({super.key, required this.param});

  @override
  State<SimilarScreenBody> createState() => _SimilarScreenBodyState();
}

class _SimilarScreenBodyState extends State<SimilarScreenBody> {
  final APIService apiService = APIService(params: "similar");

  List<Wallpaper> wallpapers = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Wallpaper> newWallpapers =
          await apiService.similarFetch(widget.param);

      setState(() {
        wallpapers.addAll(newWallpapers);

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Failed to load wallpapers: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardScreen(content: wallpapers, type: 'similar');
  }
}
