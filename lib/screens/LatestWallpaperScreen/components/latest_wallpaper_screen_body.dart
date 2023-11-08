import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/services/Api/api_service.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'package:pixelline/screens/CardScreen/card_screen.dart';
import 'package:pixelline/util/util.dart';

class LatestWallpaperScreenBody extends StatefulWidget {
  const LatestWallpaperScreenBody({super.key});

  @override
  State<LatestWallpaperScreenBody> createState() =>
      _LatestWallpaperScreenBodyState();
}

class _LatestWallpaperScreenBodyState extends State<LatestWallpaperScreenBody> {
  final APIService apiService = APIService(params: "wall/latest");

  List<Wallpaper> wallpapers = [];

  late Future<List<Wallpaper>> futureWallpapers;

  int pageNumber = 1;

  bool isLoading = false;

  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    fetchWallpapers();
  }

  @override
  void dispose() {
    super.dispose();
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
      // appBar: AppBar(title: const Text("Latest Wallpapers")),
      body: Stack(
        children: [
          const SizedBox(
            height: 200,
            width: double.infinity,
          ),
          NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: CardScreen(
              content: wallpapers,
            ),
          ),
          if (isLoading)
            // Loader widget displayed in the center of the screen
            CircularIndicator(),
        ],
      ),
    );
  }
}
