import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelline/screens/CommonScreen/common_screen.dart';
import 'package:pixelline/services/Api/api_service.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'package:pixelline/util/util.dart';

class SearchScreenBody extends StatefulWidget {
  const SearchScreenBody({super.key});

  @override
  State<SearchScreenBody> createState() => _SearchScreenBodyState();
}

class _SearchScreenBodyState extends State<SearchScreenBody> {
  final TextEditingController _searchController = TextEditingController();

  final APIService apiService = APIService(params: "random");

  List<Wallpaper> wallpapers = [];

  int pageNumber = randomIntGenrator();

  Wallpaper? randomWallpaper;

  @override
  void initState() {
    super.initState();

    fetchWallpapers().then(
      (value) => _selectRandomWallpaper(),
    );
  }

  List<Wallpaper> favoriteWallpapers = [];

  void _search() {
    String searchTerm = _searchController.text.trim();

    if (searchTerm.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommonScreen(passedData: searchTerm),
        ),
      );
    }
  }

  Future<void> fetchWallpapers() async {
    try {
      final List<Wallpaper> newWallpapers =
          await apiService.fetchWallpapers(pageNumber);

      setState(() {
        wallpapers.addAll(newWallpapers);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load wallpapers: $e');
      }
    }
  }

  void _selectRandomWallpaper() {
    if (wallpapers.isNotEmpty) {
      final random = Random();
      setState(() {
        randomWallpaper = wallpapers[random.nextInt(wallpapers.length)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(
                sigmaX: 1, sigmaY: 1), // Adjust blur strength if needed
            child: randomWallpaper != null
                ? CachedNetworkImage(
                    imageUrl: randomWallpaper!.url,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    useOldImageOnUrlChange: true,
                    fadeOutDuration: const Duration(milliseconds: 500),
                    placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularIndicator(),
                          ),
                        ))
                : Container(),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (RawKeyEvent event) {
                  if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                    _search();
                  }
                },
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _search(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                      ),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 2.0,
                          ),
                          hintText: 'Enter search term',
                          hintStyle: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 12.0, right: 8.0),
                            child: Icon(
                              Icons.search,
                              color: Colors.black54,
                              size: 24,
                            ),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _searchController.clear();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8.0, right: 12.0),
                              child: Icon(
                                Icons.clear,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                          )),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
