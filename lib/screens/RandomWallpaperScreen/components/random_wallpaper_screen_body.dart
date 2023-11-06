import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/services/api_service.dart';
import 'package:pixelline/services/wallpaper.dart';
import 'package:pixelline/screens/CardScreen/card_screen.dart';
import 'package:pixelline/util/util.dart';

class RandomWallpaperScreenBody extends StatefulWidget {
  const RandomWallpaperScreenBody({super.key});

  @override
  State<RandomWallpaperScreenBody> createState() =>
      _RandomWallpaperScreenBodyState();
}

class _RandomWallpaperScreenBodyState extends State<RandomWallpaperScreenBody> {
  final APIService apiService = APIService(params: "random");

  List<Wallpaper> wallpapers = [];

  int pageNumber = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    pageNumber = randomIntGenrator();
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Wallpaper> newWallpapers =
          await apiService.fetchWallpapers(pageNumber);

      setState(() {
        wallpapers.addAll(newWallpapers);
        pageNumber++;
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

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter <= 1400) {
      fetchWallpapers();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: CardScreen(
              content: wallpapers,
            ),
          ),
          if (isLoading)
            // Loader widget displayed in the center of the screen
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
