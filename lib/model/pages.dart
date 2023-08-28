// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pixelline/api_service.dart';
import 'package:pixelline/model/wallpaper.dart';

import 'card_screen.dart';

class ViewContainer2 extends StatefulWidget {
  final String passedData;
  final bool isView3;

  const ViewContainer2(
      {Key? key, required this.passedData, this.isView3 = false})
      : super(key: key);

  @override
  State<ViewContainer2> createState() => _ContainerState();
}

class ViewContainer3 extends StatefulWidget {
  final String passedData;

  const ViewContainer3({super.key, required this.passedData});

  @override
  State<ViewContainer3> createState() => _ContainerState2();
}

class _ContainerState extends State<ViewContainer2> {
  List<Wallpaper> wallpapers = [];
  late Future<List<Wallpaper>> futureWallpapers;
  List<Wallpaper> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];

  late APIService apiService =
      APIService(params: "search/${widget.passedData}");

  @override
  void initState() {
    super.initState();

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
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class _ContainerState2 extends State<ViewContainer3> {
  List<Wallpaper> wallpapers = [];
  late Future<List<Wallpaper>> futureWallpapers;
  List<Wallpaper> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];

  late APIService apiService =
      APIService(params: "search/views/${widget.passedData}");

  @override
  void initState() {
    super.initState();

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
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class Latest extends StatefulWidget {
  const Latest({super.key});

  @override
  State<Latest> createState() => _MyLatestState();
}

class Popular extends StatefulWidget {
  const Popular({super.key});

  @override
  State<Popular> createState() => _MyPopulartState();
}

class RandomPage extends StatefulWidget {
  const RandomPage({super.key});

  @override
  State<RandomPage> createState() => _MyRandomState();
}

class SimilarPage extends StatefulWidget {
  String param;
  SimilarPage({super.key, required this.param});

  @override
  State<SimilarPage> createState() => _MySimilarState();
}

class _MyLatestState extends State<Latest> {
  final APIService apiService = APIService(params: "wall/latest");
  List<Wallpaper> wallpapers = [];
  late Future<List<Wallpaper>> futureWallpapers;
  List<Wallpaper> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    futureWallpapers = apiService.fetchWallpapers(1);
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
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hold on'),
              content: const Text('Do you want to leave this app?'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    exit(0);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
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
            // if (isLoading)
            //   // Loader widget displayed in the center of the screen
            //   const Center(
            //     child: CircularProgressIndicator(),
            //   ),
          ],
        ),
      ),
    );
  }
}

class _MyPopulartState extends State<Popular> {
  final APIService apiService = APIService(params: "wall/popular");
  List<Wallpaper> wallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];
  late Future<List<Wallpaper>> futureWallpapers;
  List<Wallpaper> favoriteWallpapers = [];

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      // appBar: AppBar(title: const Text("Latest Wallpapers")),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: CardScreen(
              content: wallpapers,
            ),
          ),
          // if (!isLoading)
          //   // Loader widget displayed in the center of the screen
          //   const Center(
          //     child: CircularProgressIndicator(),
          //   ),
        ],
      ),
    );
  }
}

class _MyRandomState extends State<RandomPage> {
  final APIService apiService = APIService(params: "random");
  List<Wallpaper> wallpapers = [];
  int pageNumber = 145632;
  bool isLoading = false;
  List<String> favorites = [];

  late Future<List<Wallpaper>> futureWallpapers;
  List<Wallpaper> favoriteWallpapers = [];

  @override
  void initState() {
    super.initState();
    futureWallpapers = apiService.fetchWallpapers(153215);
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
          // if (isLoading)
          //   // Loader widget displayed in the center of the screen
          //   const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _MySimilarState extends State<SimilarPage> {
  final APIService apiService = APIService(params: "similar");
  List<Wallpaper> wallpapers = [];

  bool isLoading = false;
  List<String> favorites = [];
  late Future<List<Wallpaper>> futureWallpapers;
  List<Wallpaper> favoriteWallpapers = [];

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
    return CardScreen(
      content: wallpapers,
    );
  }
}
