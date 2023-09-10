import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  final String collectionId =
      '6490339aacca8d3aecf2'; // Replace with your actual collection ID
  final String databaseId =
      '649033920793f53a7112'; // Replace with your actual database ID
  bool isLoading = false;
  late bool isNew;
  late bool isOld;
  late bool isNSFW;
  bool isMounted = false;
  late RealtimeSubscription subscribtion;
  bool isNSFWEnabled = false;
  int itemsPerPage = 20; // Number of items to load per page
  int totalDocuments = 0; // Total number of documents
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
    initializing().then(
      (_) => loadFavorites(),
    );
    // loadNSFWPreference();
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
    // print(jsonStringList);
    await wallpaperStorage.restoreData();
    setState(() {
      favorites = jsonStringList;
    });
  }
  // Future<List<DocumentData>> loadFavorites(String text,
  //     {int offset = 0, int limit = 20}) async {
  //   setState(() {
  //     isLoading = text == 'loading';
  //   });

  //   try {
  //     var promise = await account.get();
  //     var email = promise.email;
  //     var name = promise.name;

  //     var listData = await databases.listDocuments(
  //       collectionId: collectionId,
  //       databaseId: databaseId,
  //       queries: [
  //         Query.equal('userEmail', email),
  //         Query.equal('userName', name),
  //         Query.limit(limit), // Use the provided limit
  //         Query.offset(offset), // Use the provided offset
  //       ],
  //     );

  //     if (isMounted) {
  //       setState(() {
  //         var loadedFavorites = listData.documents.map((document) {
  //           var data = document.data;
  //           return DocumentData(
  //             email: data['userEmail'] ?? '',
  //             name: data['userName'] ?? '',
  //             imageUrl: data['url'] ?? '',
  //             date: data['date'] ?? '',

  //           );
  //         }).toList();

  //         favorites.addAll(loadedFavorites);
  //         favorites.sort((a, b) => b.date.compareTo(a.date));
  //         isLoading = false;
  //       });

  //       return favorites;
  //     }

  //     return [];
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error fetching favorites: $e');
  //     }
  //     if (isMounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //     return [];
  //   }
  // }

  // Future<void> loadMoreFavorites() async {
  //   // Increment the current page to fetch the next page of favorites
  //   currentPage++;

  //   // Calculate the offset for the next page based on currentPage and itemsPerPage
  //   final offset = itemsPerPage * currentPage;

  //   // Calculate the number of items to load on this page
  //   final itemsToLoad = itemsPerPage;

  //   // Check if there are more items to load
  //   if (offset < totalDocuments) {
  //     // setState(() {
  //     //   isLoading = true;
  //     // });

  //     try {
  //       // Load more favorites for the updated page number
  //       final loadResult =
  //           await loadFavorites('loading', offset: offset, limit: itemsToLoad);

  //       // Check if additional favorites were loaded
  //       if (loadResult.isNotEmpty) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //       }
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print('Error loading more favorites: $e');
  //       }
  //       if (isMounted) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //       }
  //     }
  //   }
  // }

  // Future<void> sortFavorites(SortOption option) async {
  //   setState(() {
  //     currentSortOption = option;
  //     switch (currentSortOption) {
  //       case SortOption.newest:
  //         favorites.sort((a, b) => b.date.compareTo(a.date));
  //         break;
  //       case SortOption.oldest:
  //         favorites.sort((a, b) => a.date.compareTo(b.date));
  //         break;
  //       // case SortOption.isNSFW:
  //       // favorites.sort((a, b) {
  //       //   if (a.isNSFW && !b.isNSFW) {
  //       //     return -1; // NSFW items come first if isNSFW is true
  //       //   } else if (!a.isNSFW && b.isNSFW) {
  //       //     return 1; // Non-NSFW items come next if isNSFW is false
  //       //   } else {
  //       //     // If both are NSFW or both are Non-NSFW, sort by date
  //       //     return b.date.compareTo(a.date);
  //       //   }
  //       // });
  //       // // Filter the favorites to show only images where isNSFW is true
  //       // favorites =
  //       //     favorites.where((favorite) => favorite.isNSFW == true).toList();

  //       // break;
  //       // case SortOption.isNotNSFW:
  //       // favorites.sort((a, b) {
  //       //   if (!a.isNSFW && b.isNSFW) {
  //       //     return -1; // Non-NSFW items come first if isNSFW is false
  //       //   } else if (a.isNSFW && !b.isNSFW) {
  //       //     return 1; // NSFW items come next if isNSFW is true
  //       //   } else {
  //       //     // If both are NSFW or both are Non-NSFW, sort by date
  //       //     return b.date.compareTo(a.date);
  //       //   }
  //       // });
  //       // // Filter the favorites to show only images where isNSFW is false
  //       // favorites =
  //       //     favorites.where((favorite) => !favorite.isNSFW == true).toList();
  //       // break;
  //     }
  //   });
  // }

  // void _openMenu() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
  //     ),
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: const EdgeInsets.symmetric(vertical: 18.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             ListTile(
  //               onTap: () async {
  //                 Navigator.pop(
  //                   context,
  //                   SortOption.newest,
  //                 );
  //               },
  //               selected: currentSortOption == SortOption.newest,
  //               tileColor: currentSortOption == SortOption.newest
  //                   ? Colors.grey[200]
  //                   : null,
  //               title: Text(
  //                 'Newest',
  //                 style: TextStyle(
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.bold,
  //                   color: currentSortOption == SortOption.newest
  //                       ? Colors.black
  //                       : Colors.grey,
  //                 ),
  //               ),
  //             ),
  //             ListTile(
  //               onTap: () async {
  //                 Navigator.pop(context, SortOption.oldest);
  //               },
  //               selected: currentSortOption == SortOption.oldest,
  //               tileColor: currentSortOption == SortOption.oldest
  //                   ? Colors.grey[200]
  //                   : null,
  //               title: Text(
  //                 'Oldest',
  //                 style: TextStyle(
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.bold,
  //                   color: currentSortOption == SortOption.oldest
  //                       ? Colors.black
  //                       : Colors.grey,
  //                 ),
  //               ),
  //             ),
  //             // ListTile(
  //             //   onTap: () async {
  //             //     await loadFavorites('noLoading').then(
  //             //       (value) => Navigator.pop(context, SortOption.isNSFW),
  //             //     );
  //             //   },
  //             //   selected: currentSortOption == SortOption.isNSFW,
  //             //   tileColor: currentSortOption == SortOption.isNSFW
  //             //       ? Colors.grey[200]
  //             //       : null,
  //             //   title: Text(
  //             //     'NSFW',
  //             //     style: TextStyle(
  //             //       fontSize: 15,
  //             //       fontWeight: FontWeight.bold,
  //             //       color: currentSortOption == SortOption.isNSFW
  //             //           ? Colors.black
  //             //           : Colors.grey,
  //             //     ),
  //             //   ),
  //             // ),
  //             // ListTile(
  //             //   onTap: () async {
  //             //     await loadFavorites('noLoading').then(
  //             //       (value) => Navigator.pop(context, SortOption.isNotNSFW),
  //             //     );
  //             //   },
  //             //   selected: currentSortOption == SortOption.isNotNSFW,
  //             //   tileColor: currentSortOption == SortOption.isNotNSFW
  //             //       ? Colors.grey[200]
  //             //       : null,
  //             //   title: Text(
  //             //     'Not NSFW',
  //             //     style: TextStyle(
  //             //       fontSize: 15,
  //             //       fontWeight: FontWeight.bold,
  //             //       color: currentSortOption == SortOption.isNotNSFW
  //             //           ? Colors.black
  //             //           : Colors.grey,
  //             //     ),
  //             //   ),
  //             // ),
  //           ],
  //         ),
  //       );
  //     },
  //   ).then((value) {
  //     if (value != null) {
  //       setState(() {
  //         currentSortOption = value;
  //         sortFavorites(currentSortOption);
  //       });
  //       if (kDebugMode) {
  //         print('Selected option: $value');
  //       }
  //     }
  //   });
  // }

  void subscribe() {
    subscribtion = realtime.subscribe(['documents']);
    subscribtion.stream.listen((event) {
      final eventType = event.events;
      final payload = event.payload;

      if (eventType.contains('databases.*.collections.*.documents.*.create')) {
        handleDocumentCreation(payload);
      } else if (eventType
          .contains('databases.*.collections.*.documents.*.delete')) {
        handleDocumentUpdate(payload);
      }
    });
  }

  void handleDocumentCreation(Map<String, dynamic> payload) {
    setState(() {
      loadFavorites();
    });

    // Perform additional actions for document creation
  }

  void handleDocumentUpdate(Map<String, dynamic> payload) {
    setState(() {
      loadFavorites();
    });

    // Perform additional actions for document update
  }

  // Future<void> loadNSFWPreference() async {
  //   try {
  //     var promise = await account.getPrefs();
  //     var isNSFWEnabledData = promise.data['isNSFW'];
  //     setState(() {
  //       isNSFWEnabled =
  //           isNSFWEnabledData ?? false; // Assign default value if not set
  //     });
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error fetching NSFW preference: $e');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('isNSFW =$isNSFWEnabled ');
    }
    if (kDebugMode) {
      print(isNew);
      print(isOld);
    }
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          mainAxisExtent: 300,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final favorite = filteredFavorites[index];
                            print(favorite.url);
                            if (index == filteredFavorites.length) {
                              return Container(
                                color: Colors.transparent,
                                child: const CupertinoActivityIndicator(
                                    radius: 20),
                              );
                            }
                            // Exclude URLs containing "slxftlarogkbsdtwepdn.supabase.co"

                            // Show images based on isNSFWEnabled and favorite.isNSFW
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
                          childCount: filteredFavorites
                              .length, // +1 for the loading indicator
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
          // Positioned(
          //   width: 110,
          //   height: 45,
          //   bottom: 80,
          //   right: 20,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(29),
          //     child: ElevatedButton(
          //       style: ButtonStyle(
          //         backgroundColor: MaterialStateProperty.resolveWith<Color>(
          //           (Set<MaterialState> states) {
          //             if (states.contains(MaterialState.pressed)) {
          //               return const Color.fromARGB(
          //                   255, 28, 28, 29); // Color when button is pressed
          //             } else if (states.contains(MaterialState.hovered)) {
          //               return const Color.fromARGB(
          //                   255, 18, 18, 19); // Color when button is hovered
          //             } else {
          //               return Colors.black; // Default color
          //             }
          //           },
          //         ),
          //       ),
          //       onPressed: _openMenu,
          //       child: const Padding(
          //         padding: EdgeInsets.all(8.0),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceAround,
          //           children: [
          //             Icon(
          //               Icons.sort,
          //               color: Colors.white,
          //             ),
          //             Text(
          //               'sort',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 15,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
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
