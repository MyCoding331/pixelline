import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/model/card_screen.dart';
import 'package:pixelline/model/wallpaper.dart';
import 'package:pixelline/api_service.dart';

class Search extends StatefulWidget {
  final String searchText;

  const Search({Key? key, required this.searchText}) : super(key: key);

  @override
  State<Search> createState() => _MySearchState();
}

class _MySearchState extends State<Search> {
  List<Wallpaper> wallpapers = [];
  late Future<List<Wallpaper>> futureWallpapers;
  List<Wallpaper> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];

  late APIService apiService =
      APIService(params: "search/${widget.searchText}");

  @override
  void initState() {
    super.initState();
    // final APIService apiService = APIService(params: widget.passedData);
    futureWallpapers = apiService.fetchWallpapers(1);
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
    if (wallpapers.isEmpty) {
      const Center(
        child: Text(
          'No Search result Found',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
          ),
        ),
      );
    }
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: CardScreen(
          content: wallpapers,
        ),
      ),
    );
  }
}
