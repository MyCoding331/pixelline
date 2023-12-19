import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/helper/databse.dart';
import 'package:pixelline/screens/FavoriteScreen/components/favorite_card.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'package:pixelline/util/functions.dart';
import 'package:pixelline/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreenBody extends StatefulWidget {
  const FavoriteScreenBody({super.key});

  @override
  State<FavoriteScreenBody> createState() => _FavoriteScreenBodyState();
}

enum SortOption {
  newest,
  oldest,
}

class _FavoriteScreenBodyState extends State<FavoriteScreenBody> {
  final ScrollController _scrollController = ScrollController();
  List<Wallpaper> favorites = [];
  int currentPage = 1;
  SortOption currentSortOption = SortOption.newest;
  var dbHelper = WallpaperDatabaseHelper();
  bool isLoading = true;
  late bool isNew;
  late bool isOld;
  late bool isNSFW;
  bool isMounted = false;
  late RealtimeSubscription subscribtion;
  bool isNSFWEnabled = false;
  int itemsPerPage = 20;
  int totalDocuments = 0;
  late Future<void> initialization;
  late final WallpaperStorage<Wallpaper> wallpaperStorage;
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    isMounted = true;
    isNew = true;
    isOld = false;
    isNSFW = false;

    showNoFavoritesMessage();
    initializing().then(
      (_) => loadFavorites(),
    );
  }

  Future<void> initializing() async {
    final pref = await SharedPreferences.getInstance();
    // subscribe();
    setState(
      () {
        prefs = pref;
        wallpaperStorage = WallpaperStorage<Wallpaper>(
          storageKey: 'favorites',
          fromJson: (json) => Wallpaper.fromJson(json),
          toJson: (data) => data.toJson(),
          prefs: pref,
        );
      },
    );
  }

  Future<void> loadFavorites() async {
    List<Wallpaper> jsonStringList =
        await loadFavs(wallpaperStorage: wallpaperStorage);

    dynamic data = await dbHelper.getWallpapers();
    setState(() {
      favorites = data;
    });
  }

  // void subscribe() {
  //   realtimeUpdate(subscribtion: subscribtion, loadFavorites: loadFavorites);
  // }

  void showNoFavoritesMessage() {
    Future.delayed(const Duration(seconds: 2), () {
      if (isMounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredFavorites = favorites;

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: loadFavorites(),
              builder: (context, snapShot) {
                return FavoriteCard(
                  filteredFavorites: filteredFavorites,
                  scrollController: _scrollController,
                );
              }),
          if (isLoading) CircularIndicator(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    isMounted = false;
    subscribtion.close();

    // Dispose any resources, such as canceling timers or stopping listeners.
  }
}
