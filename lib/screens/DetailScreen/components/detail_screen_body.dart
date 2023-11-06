// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:like_button/like_button.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pixelline/components/ads_units_ids.dart';
import 'package:pixelline/services/wallpaper.dart';
import 'package:pixelline/screens/SimilarScreen/similar_screen.dart';
import 'package:pixelline/screens/TagScreen/tag_screen.dart';
import 'package:pixelline/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreenBody extends StatefulWidget {
  final String imageUrl;
  final String imageId;
  Wallpaper wallpaper;
  final bool isNSFW;

  DetailScreenBody({
    Key? key,
    required this.imageUrl,
    required this.wallpaper,
    this.isNSFW = false,
    this.imageId = '',
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DetailScreenBodyState createState() => _DetailScreenBodyState();
}

class _DetailScreenBodyState extends State<DetailScreenBody> {
  bool isLoading = false;
  late bool isFavorite;
  bool onDownloadIsLoading = false;
  bool isWallpaperSet = false;
  bool isDownloaded = false;
  static const double iconSize = 30;
  List<Wallpaper> documents = [];
  late final WallpaperStorage<Wallpaper> wallpaperStorage;
  final String collectionId =
      '6490339aacca8d3aecf2'; // Replace with your actual collection ID
  final String databaseId =
      '649033920793f53a7112'; // Replace with your actual database ID
  int _selectedIndex = 0;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    initializing().then((_) => loadFavorites());
    isFavorite = false;
    checkIfInFavorites(widget.imageUrl);
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adsInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // _moveToHome();
              // Navigator.pop(context, true);
              downloadImage(
                widget.imageUrl
                    .replaceAll("wallpapers/thumb", "download")
                    .replaceAll(".jpg", "-1080x1920.jpg"),
              );
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('Failed to load an interstitial ad: ${err.message}');
          }
        },
      ),
    );
    RewardedAd.load(
      adUnitId: adsRewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadInterstitialAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('Failed to load a rewarded ad: ${err.message}');
          }
        },
      ),
    );
  }

  Future<void> initializing() async {
    final prefs = await SharedPreferences.getInstance();
    final newData = WallpaperStorage<Wallpaper>(
        storageKey: 'favorites',
        fromJson: (json) => Wallpaper.fromJson(json),
        toJson: (videos) => videos.toJson(),
        prefs: prefs);
    setState(() {
      wallpaperStorage = newData;
    });
  }

  Future<void> downloadImage(String imageUrl) async {
    String downloadsPath;
    setState(() {
      onDownloadIsLoading = true;
      // isDownloaded = true;
    });
    if (onDownloadIsLoading == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black54,
          // dismissDirection: DismissDirection.up,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Wallpaper is downloading',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      null;
    }
    try {
      final response = await http.get(Uri.parse(imageUrl));

      downloadsPath = (await getDownloadsDirectory())!.path;

      // Create the directory if it doesn't exist
      final directory = Directory(downloadsPath);
      if (!await directory.exists()) {
        directory.create(recursive: true);
      }
      final newImageName = randomStringGenerataor(20);
      final imageFile = File('$downloadsPath/$newImageName.jpg');
      await imageFile.writeAsBytes(response.bodyBytes);

      setState(() {
        onDownloadIsLoading = false;
        isDownloaded = true;
      });

      if (isDownloaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Colors.black54,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Downloaded successfully',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      if (kDebugMode) {
        print('Image saved to: ${imageFile.path}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Failed to download image: $error');
      }
      downloadsPath = 'Failed to get downloads path';
    }
  }

  Future<void> setWallpaper(
      String imageUrl, int type, BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final wallpaperTypes = [
      WallpaperManager.HOME_SCREEN,
      WallpaperManager.LOCK_SCREEN,
      WallpaperManager.BOTH_SCREEN,
    ];

    final wallpaperLabels = [
      'HomeScreen',
      'LockScreen',
      'BothScreen',
    ];

    final wallpaperType = type.clamp(0, 2);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black54,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Setting Wallpaper in ${wallpaperLabels[wallpaperType]}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    Future<File> downloadImageInSet(String imageUrl) async {
      final response = await http.get(Uri.parse(imageUrl));
      final appDir = await getTemporaryDirectory();

      final newImageUrl = randomStringGenerataor(20);
      final file = File('${appDir.path}/$newImageUrl');

      await file.writeAsBytes(response.bodyBytes);
      return file;
    }

    try {
      final file = await downloadImageInSet(imageUrl);
      final result = await WallpaperManager.setWallpaperFromFile(
          file.path, wallpaperTypes[wallpaperType]);

      if (result) {
        setState(() {
          isLoading = false;
          isWallpaperSet = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Colors.black54,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Failed to set wallpaper',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black54,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Wallpaper Set at ${wallpaperLabels[wallpaperType]}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black54,
          behavior: SnackBarBehavior.floating,
          content: Text(
            error.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // if (kDebugMode) {
    //   print(isWallpaperSet);
    // }
  }

  bool checkIfInFavorites(id) {
    for (var document in documents) {
      if (document.id == id) {
        return true;
      }
    }
    return false;
  }

  Future<void> loadFavorites() async {
    final jsonStringList = await wallpaperStorage.getDataList();
    await wallpaperStorage.restoreData();
    setState(() {
      documents = jsonStringList;
    });
  }

  Future<void> addToFavorites(Wallpaper item) async {
    Wallpaper videos = item;
    documents.add(item);
    // print(item.url);
    await wallpaperStorage.storeData(videos, context).then(
          (_) => loadFavorites(),
        );
  }

  Future<void> removeFromFavorites(id) async {
    await wallpaperStorage.removeData(id, context).then(
          (_) => loadFavorites(),
        );
  }

  void showRemoveDialog(BuildContext context, String imageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                "Warning..!!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Text("Are you sure you want to remove this item?"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 16.0)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                removeFromFavorites(imageId).then((_) => loadFavorites());
                Navigator.of(context).pop(true);
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              label: const Text("Remove", style: TextStyle(fontSize: 16.0)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> toggleFavorite(context, image, index) async {
    if (checkIfInFavorites(image)) {
      showRemoveDialog(context, image);
    } else {
      await addToFavorites(image);
      loadFavorites();
    }
    return true; // Return true to indicate that the like state has been changed
  }

  Future<bool?> onLikeButtonTap(
      bool isLiked, context, Wallpaper wallpaper) async {
    // Check if the image is in favorites
    bool isInFavorites = checkIfInFavorites(wallpaper.id);

    if (isInFavorites) {
      // If it's in favorites, show the remove dialog and return false
      showRemoveDialog(context, wallpaper.id);
      return false;
    } else {
      // If it's not in favorites, add it and return true
      await addToFavorites(wallpaper);
      loadFavorites();
      return true;
    }
  }

  Future<void> _showConfirmationDialog(
    String modifiedImage,
    BuildContext context,
  ) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Wallpaper Screen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.home, size: 30, color: Colors.black),
                title: const Text(
                  'Home Screen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () {
                  // Handle "Home Screen" button action
                  setWallpaper(modifiedImage, 0, context);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.lock, size: 30, color: Colors.black),
                title: const Text(
                  'Lock Screen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () {
                  // Handle "Lock Screen" button action
                  setWallpaper(modifiedImage, 1, context);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.phone_android,
                    size: 30, color: Colors.black),
                title: const Text(
                  'Both Screen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () {
                  // Handle "Both Screen" button action
                  setWallpaper(modifiedImage, 2, context);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTab(0, Icons.new_releases, 'Tags'),
              _buildTab(1, Icons.local_fire_department, 'Similar'),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        if (kDebugMode) {
          print('Selected option: $value');
        }
      }
    });
  }

  void openSubMenu(int index) {
    double screenHeight = MediaQuery.of(context).size.height;
    double desiredHeight = screenHeight * 0.7;

    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: index == 0 ? false : true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        if (index == 0) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
            ),
            child: TagScreen(
              param: widget.imageId,
            ),
          );
        } else {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
            ),
            height: desiredHeight,
            child: SimilarScreen(
              param: widget.imageId,
            ),
          );
        }
      },
    ).then((value) {
      if (value != null) {
        // Handle selected option here
        if (kDebugMode) {
          print('Selected option: $value');
        }
      }
    });
  }

  Widget _buildTab(int index, IconData icon, String title) {
    // final isSelected = index == _selectedIndex;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          openSubMenu(
              _selectedIndex); // Close the bottom sheet and pass the selected title
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 24,
            color: Colors.grey[600],
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.imageId);
    final modifiedImage = widget.imageUrl
        .replaceAll("wallpapers/thumb", "download")
        .replaceAll(".jpg", "-1080x1920.jpg");
    final uniqueTag = UniqueKey().toString();

    return WillPopScope(
      onWillPop: () async {
        // Call loadFavorites function when the back button is pressed
        loadFavorites();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                  sigmaX: 50,
                  sigmaY:
                      50), // Adjust the sigmaX and sigmaY for blur intensity
              child: CachedNetworkImage(
                imageUrl: modifiedImage,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 35,
                  ),

                  // Image wrapped in Hero widget
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Hero(
                        tag: uniqueTag,
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: modifiedImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 3.0,
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Buttons wrapped in Align widget
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 55,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (!isLoading && _rewardedAd != null) {
                                  _rewardedAd?.show(
                                    onUserEarnedReward: (_, reward) {
                                      _showConfirmationDialog(
                                        modifiedImage,
                                        context,
                                      );
                                    },
                                  );
                                } else {
                                  _showConfirmationDialog(
                                    modifiedImage,
                                    context,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(1200),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: buildFloatingActionButtonChild(),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_interstitialAd != null) {
                                  _interstitialAd?.show();
                                } else {
                                  downloadImage(
                                    modifiedImage,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(1200),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child:
                                    buildFloatingActionButtonChildForDownload(),
                              ),
                            ),
                          ),
                          LikeButton(
                            onTap: (isLiked) => onLikeButtonTap(
                                isLiked, context, widget.wallpaper),
                            size: 42,
                            likeBuilder: (bool isLiked) {
                              bool isInFavorites =
                                  checkIfInFavorites(widget.wallpaper.id);
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20000),
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Icon(
                                    Icons.favorite,
                                    color: isInFavorites
                                        ? Colors.red
                                        : Colors.white,
                                    size: 22,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (widget.isNSFW == false)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _openMenu();
                                },
                                borderRadius: BorderRadius.circular(1200),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.more_vert_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFloatingActionButtonChild() {
    if (isLoading) {
      return const SizedBox(
        width: 25.0,
        height: 25.0,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3.0,
        ),
      );
    } else {
      if (isWallpaperSet) {
        return const Icon(
          Icons.done,
          size: iconSize,
          color: Colors.white,
        );
      } else {
        return const Icon(
          Icons.wallpaper,
          size: iconSize,
          color: Colors.white,
        );
      }
    }
  }

  Widget buildFloatingActionButtonChildForDownload() {
    if (onDownloadIsLoading) {
      return const SizedBox(
        width: 25.0,
        height: 25.0,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3.0,
        ),
      );
    } else {
      if (isDownloaded) {
        return const Icon(
          Icons.done,
          size: iconSize,
          color: Colors.white,
        );
      } else {
        return const Icon(
          Icons.download,
          size: iconSize,
          color: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose any resources, such as canceling timers or stopping listeners.
  }
}
