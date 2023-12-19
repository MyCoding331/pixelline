import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/screens/CardScreen/card_screen.dart';
import 'package:pixelline/services/Api/api_service.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'package:pixelline/util/functions.dart';
import 'package:pixelline/util/util.dart';

class CommonScreenBody extends StatefulWidget {
  final String passedData;

  const CommonScreenBody({super.key, required this.passedData});

  @override
  State<CommonScreenBody> createState() => _CommonScreenBodyState();
}

class _CommonScreenBodyState extends State<CommonScreenBody> {
  List<Wallpaper> wallpapers = [];

  List<Wallpaper> favoriteWallpapers = [];

  int pageNumber = 1;

  bool isLoading = false;

  List<String> favorites = [];

  late APIService apiService =
      APIService(params: "search/${widget.passedData}");

  @override
  void initState() {
    super.initState();
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;

    try {
      setState(() {
        isLoading = true;
      });
      List<Wallpaper> newWallpapers = await commonFetch(apiService, pageNumber);

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
          if (isLoading == true) CircularIndicator(),
        ],
      ),
    );
  }
}
