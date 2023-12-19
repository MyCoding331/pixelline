// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixelline/components/AdUnits/ads_units_ids.dart';
import 'package:pixelline/services/Appwrite/appwrite_sevices.dart';
import 'package:pixelline/components/TabBar/tab_bar.dart';
import 'package:pixelline/screens/AuthScreen/auth_screen.dart';
import 'package:pixelline/screens/CategorieScreen/categorie_screen.dart';
import 'package:pixelline/screens/FavoriteScreen/favorite_screen.dart';
import 'package:pixelline/screens/SearchScreen/search_screen.dart';
import 'package:pixelline/screens/SettingScreen/setting_screen.dart';
import 'package:pixelline/util/functions.dart';
import 'package:pixelline/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({Key? key}) : super(key: key);

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen>
    with TickerProviderStateMixin {
  int pageIndex = 0;
  double iconSize = 25.0;

  BannerAd? _bannerAd;
  BannerAd? _newBannerAd;
  @override
  void initState() {
    super.initState();
    setUserDetails();

    initializeingBanner();
    checkUserSession();
  }

  void initializeingBanner() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await BannerAd(
      adUnitId: adsBanner,
      request: const AdRequest(),
      size: AdSize.fluid,
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
          await prefs.setBool('BANNER_AD', true);
        },
        onAdFailedToLoad: (ad, err) async {
          if (kDebugMode) {
            print('Failed to load a banner ad: ${err.message}');
          }
          await prefs.setBool('BANNER_AD', false);
          // ad.dispose();
        },
      ),
    ).load();

    await BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _newBannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          if (kDebugMode) {
            print('Failed to load a banner ad: ${err.message}');
          }
          setState(() {
            _newBannerAd = ad as BannerAd;
          });
          // ad.dispose();
        },
      ),
    ).load();
  }

  // final pages = <Widget>[];

  @override
  void dispose() {
    _bannerAd?.dispose();
    _newBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // pages.addAll([
    //   const TabBarContainer(),
    //   const FavoriteScreen(),
    //   const CategorieScreen(),
    //   const SearchScreen(),
    // ]);

    if (kDebugMode) {
      print(
        'Screen Width: ${width.toStringAsFixed(2)}\nScreen Height: ${height.toStringAsFixed(2)}',
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
                title: Text(
                  _getAppBarTitle(pageIndex),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: leadingWidget(),
                shadowColor: Colors.transparent,
                backgroundColor: Colors.white,
              ),
        // appBar(
        //     text: _getAppBarTitle(pageIndex),
        //     leading: leadingWidget(),
        //     backButton: false),
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              Row(
                children: [
                  if (width >= 700)
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
                    flex: width >= 700 ? 7 : 1,
                    child: IndexedStack(
                      index: pageIndex,
                      children: const [
                        TabBarContainer(),
                        FavoriteScreen(),
                        CategorieScreen(),
                        SearchScreen(),
                      ],
                    ),
                  ),
                ],
              ),
              if (width <= 700)
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
              if (_bannerAd != null &&
                  _getAppBarTitle(pageIndex) != "Search" &&
                  _getAppBarTitle(pageIndex) != "Favorites")
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Builder leadingWidget() {
    return Builder(
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
              await account.deleteSessions();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
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
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                    style: const TextStyle(
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
