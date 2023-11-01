import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/api_service.dart';
import 'package:pixelline/model/appwrite_sevices.dart';
import 'package:pixelline/model/wallpaper.dart';
import 'package:pixelline/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_screen.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FavScreenState createState() => _FavScreenState();
}

enum SortOption {
  newest,
  oldest,
}

class _FavScreenState extends State<FavScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Wallpaper> favorites = [];
  int currentPage = 1;
  SortOption currentSortOption = SortOption.newest;
  final String collectionId = '6490339aacca8d3aecf2';
  final String databaseId = '649033920793f53a7112';
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

    subscribe();
  }

  Future<void> initializing() async {
    final pref = await SharedPreferences.getInstance();

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
    final jsonStringList = await wallpaperStorage.getDataList();

    await wallpaperStorage.restoreData();
    setState(() {
      favorites = jsonStringList;
    });
  }

  void subscribe() {
    subscribtion = realtime.subscribe(['documents']);
    subscribtion.stream.listen((event) {
      final eventType = event.events;
      final payload = event.payload;

      if (eventType.contains('databases.*.collections.*.documents.*.create')) {
        handleDocumentCreation(payload);
      } else if (eventType.contains('databases.*.collections.*.documents.*.delete')) {
        handleDocumentUpdate(payload);
      }
    });
  }

  void handleDocumentCreation(Map<String, dynamic> payload) {
    setState(() {
      loadFavorites();
    });
  }

  void handleDocumentUpdate(Map<String, dynamic> payload) {
    setState(() {
      loadFavorites();
    });
  }

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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            reverseDuration: const Duration(milliseconds: 100),
            switchInCurve: Curves.easeInExpo,
            switchOutCurve: Curves.easeOutExpo,
            child: filteredFavorites.isNotEmpty
                ? CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          mainAxisExtent: 300,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final favorite = filteredFavorites[index];

                            if (index == filteredFavorites.length) {
                              return Container(
                                color: Colors.transparent,
                                child: const CupertinoActivityIndicator(radius: 20),
                              );
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageDetailsScreen(
                                      imageUrl: favorite.url,
                                      wallpaper: favorite,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: ImageComponent(imagePath: favorite.url),
                              ),
                            );
                          },
                          childCount: filteredFavorites.length, // +1 for the loading indicator
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 50,
                        ), // Add some whitespace at the end
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      "No Favorites Found",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 29,
                      ),
                    ),
                  ),
          ),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
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
