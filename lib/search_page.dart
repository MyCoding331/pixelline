import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelline/api_service.dart';
import 'package:pixelline/container_screen.dart';
import 'package:pixelline/model/wallpaper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final APIService apiService = APIService(params: "random");
  List<Wallpaper> wallpapers = [];
  int pageNumber = 145632;
  // bool isLoading = false;
  List<String> favorites = [];
  Wallpaper? randomWallpaper;

  @override
  void initState() {
    super.initState();
    // final APIService apiService = APIService(params: widget.passedData);

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
          builder: (context) => ViewContainer(passedData: searchTerm),
        ),
      );
    }
  }

  Future<void> fetchWallpapers() async {
    // if (isLoading) return;
    // setState(() {
    //   isLoading = true;
    // });

    try {
      final List<Wallpaper> newWallpapers =
          await apiService.fetchWallpapers(pageNumber);

      setState(() {
        wallpapers.addAll(newWallpapers);
      });
    } catch (e) {
      // setState(() {
      //   isLoading = false;
      // });
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
        // isLoading = false;
      });
    }
  }

  List<String> imageData = [
    'assets/images/categ/superheroes.jpg',
    "assets/images/categ/games.webp",
    "assets/images/categ/creative.webp",
    "assets/images/categ/bikes.jpg",
    "assets/images/categ/cars.jpg",
    "assets/images/categ/3d.jpg",
    "assets/images/categ/nature.jpg",
    "assets/images/categ/tv-shows.jpg",
    "assets/images/categ/movies.jpg",
    "assets/images/categ/celebration.jpg",
    "assets/images/categ/computer.jpg",
    "assets/images/categ/planes.jpg",
    "assets/images/categ/sports.jpg",
    "assets/images/categ/animals.jpg",
    "assets/images/categ/logos.jpg",
    "assets/images/categ/inspiration.jpg",
    "assets/images/categ/artist.jpg",
    "assets/images/categ/typography.jpg",
    "assets/images/categ/cute.jpg",
    "assets/images/categ/girls.jpg",
    "assets/images/categ/abstract.jpg",
    "assets/images/categ/birds.jpg",
    "assets/images/categ/graphics.jpg",
    "assets/images/categ/world.jpg",
    "assets/images/categ/flowers.jpg",
    "assets/images/categ/photography.jpg",
    "assets/images/categ/celebration.jpg",
    "assets/images/categ/music.jpg",
    "assets/images/categ/insian-celebs.jpg",
    "assets/images/categ/digital-universe.jpg",
    "assets/images/categ/love.webp",
    "assets/images/categ/fantasy-girls.jpg",
    "assets/images/categ/anime.jpg",
    "assets/images/categ/cartoons.jpg",
    "assets/images/categ/others.webp",
    "assets/images/categ/lifestyle.png",
    "assets/images/categ/food.webp",
  ];
  String getRandomImage(List<String> imageList) {
    Random random = Random();
    int index = random.nextInt(imageList.length);
    return imageList[index];
  }

  @override
  Widget build(BuildContext context) {
    String randomImagePath = getRandomImage(imageData);
    String inputText = '';
    // print(randomImagePath);
    // print(randomWallpaper!.url);
    return Scaffold(
      body: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(
                sigmaX: 2, sigmaY: 2), // Adjust blur strength if needed
            child: randomWallpaper != null
                ? CachedNetworkImage(
                    imageUrl: randomWallpaper!.url,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    useOldImageOnUrlChange: true,
                    fadeOutDuration: const Duration(milliseconds: 500),
                    placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(strokeWidth: 3.0),
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
                      // autofocus: true,
                      controller: _searchController,
                      onChanged: (value) => {
                        setState(() {
                          inputText = value;
                        })
                      },
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
                          suffixIcon:
                              // inputText != ''
                              //     ?
                              GestureDetector(
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
                          )
                          // : null,
                          ),
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
