import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelline/api_service.dart';
import 'package:pixelline/categories.dart';
import 'package:pixelline/model/appwrite_sevices.dart';
import 'package:pixelline/model/tab_bar.dart';
import 'package:pixelline/search_page.dart';
import 'package:pixelline/storage_screen.dart';
import 'package:pixelline/fav_screen.dart';
import 'package:pixelline/container_screen.dart';
import 'package:pixelline/model/setting_page.dart';
import 'package:pixelline/model/Auth/auth.dart';

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({Key? key}) : super(key: key);

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen>
    with TickerProviderStateMixin {
  final APIService apiService = APIService(params: "popular/1");
  int pageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  List<String> favorites = [];
  bool _isAppBarExpanded = false;

  double iconSize = 25.0;

  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _isAppBarExpanded = _scrollController.offset > kToolbarHeight + 50;
      });
      _controller;
      // loadFavorites();
    });

    checkUserSession();
  }

  final pages = <Widget>[];
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

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

  Future<bool> checkUserSession() async {
    try {
      // Check if the user session exists
      await account.get();
      return true;
    } catch (e) {
      // Handle any errors that occurred while checking the user session
      if (kDebugMode) {
        print('Error: $e');
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    pages.addAll([
      TabBarContainer(),
      const FavScreen(),
      const Categories(),
      const SearchPage(),
      // const StorageScreen(),
    ]);
    final screenSize = MediaQuery.of(context).size;
    double screenWidth = MediaQuery.of(context).size.width;
    if (kDebugMode) {
      print(
        'Screen Width: ${screenSize.width.toStringAsFixed(2)}\nScreen Height: ${screenSize.height.toStringAsFixed(2)}',
      );
    }
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0x00000070),
        appBar: _getAppBarTitle(pageIndex) == "Search"
            ? null
            : AppBar(
                automaticallyImplyLeading: false,
                title: _isSearching
                    ? RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (RawKeyEvent event) {
                          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                            _search();
                          }
                        },
                        child: TextField(
                          autofocus: true,
                          controller: _searchController,
                          onSubmitted: (_) => _search(),
                          decoration: InputDecoration(
                            hintText: 'Enter search term',
                            filled: false,
                            isCollapsed: true,
                            hintStyle: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        _getAppBarTitle(pageIndex),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                leading: Builder(
                  builder: (BuildContext context) {
                    return PopupMenuButton<String>(
                      onSelected: (String value) async {
                        if (value == 'profile') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingScreen(),
                            ),
                          );
                        }
                        if (value == 'logout') {
                          await account.deleteSession(sessionId: 'current');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthPage(),
                            ),
                          );
                        }
                        if (kDebugMode) {
                          print('Selected value: $value');
                        }
                      },
                      tooltip: "profile",
                      position: PopupMenuPosition.under,
                      elevation: 4,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: ListTile(
                            leading: Icon(Icons.settings),
                            title: Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout_rounded),
                            title: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      icon: const Icon(
                        Icons.person_rounded,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: AnimatedCrossFade(
                      firstChild: const Icon(Icons.search),
                      secondChild: const Icon(Icons.close),
                      crossFadeState: _isSearching
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 500),
                    ),
                    color: Colors.black,
                    onPressed: () {
                      _toggleSearch();
                    },
                  )
                ],
                shadowColor: Colors.transparent,
                backgroundColor: Colors.white,
              ),
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              Row(
                children: [
                  if (screenWidth >= 700)
                    Expanded(
                      child: SizedBox(
                        width: 100,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  pageIndex = 0;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: pageIndex == 0
                                    ? Colors.black
                                    : Colors.white,
                                padding: const EdgeInsets.all(20),
                                shadowColor: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.home,
                                size: iconSize,
                                color: pageIndex == 0
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  pageIndex = 1;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: pageIndex == 1
                                    ? Colors.black
                                    : Colors.white,
                                padding: const EdgeInsets.all(22),
                                shadowColor: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.favorite_outline,
                                size: iconSize,
                                color: pageIndex == 1
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  pageIndex = 2;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: pageIndex == 2
                                    ? Colors.black
                                    : Colors.white,
                                padding: const EdgeInsets.all(22),
                                shadowColor: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.category_outlined,
                                size: iconSize,
                                color: pageIndex == 2
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  pageIndex = 3;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: pageIndex == 3
                                    ? Colors.black
                                    : Colors.white,
                                padding: const EdgeInsets.all(22),
                                shadowColor: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.search,
                                size: iconSize,
                                color: pageIndex == 3
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    flex: screenWidth >= 700 ? 7 : 1,
                    child: pages[pageIndex],
                  ),
                ],
              ),
              if (screenWidth <= 700)
                Positioned(
                  bottom: 10,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildIconButtonWithText(
                          Icons.home,
                          pageIndex == 0,
                          'Home',
                          () {
                            setState(() {
                              pageIndex = 0;
                            });
                          },
                        ),
                        buildIconButtonWithText(
                          Icons.favorite_outline,
                          pageIndex == 1,
                          'Favorites',
                          () {
                            setState(() {
                              pageIndex = 1;
                            });
                          },
                        ),
                        buildIconButtonWithText(
                          Icons.category_outlined,
                          pageIndex == 2,
                          'Categories',
                          () {
                            setState(() {
                              pageIndex = 2;
                            });
                          },
                        ),
                        buildIconButtonWithText(
                          Icons.search,
                          pageIndex == 3,
                          'Search',
                          () {
                            setState(() {
                              pageIndex = 3;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildIconButtonWithText(
    IconData icon, bool isSelected, String label, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2000),
            ),
            backgroundColor: !isSelected ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal:18,vertical:10),
            shadowColor: Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 23,
                color: !isSelected ? Colors.white : Colors.black,
              ),
              Visibility(
                visible: isSelected,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    label,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _getAppBarTitle(int currentIndex) {
  switch (currentIndex) {
    case 0:
      return 'Home';
    case 1:
      return 'Favorites';
    case 2:
      return 'Categories';
    case 3:
      return 'Search';
    default:
      return 'Home';
  }
}
