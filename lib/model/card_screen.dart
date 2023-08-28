// ignore_for_file: library_private_types_in_public_api

import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

import 'package:pixelline/model/appwrite_sevices.dart';
import 'package:pixelline/model/wallpaper.dart';
import '../api_service.dart';
import '../detail_screen.dart';

class CardScreen extends StatefulWidget {
  final List<Wallpaper> content;

  const CardScreen({Key? key, required this.content}) : super(key: key);

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  List<DocumentData> documents = [];
  // List<String> favorites = [];
  final String collectionId =
      '6490339aacca8d3aecf2'; // Replace with your actual collection ID
  final String databaseId =
      '649033920793f53a7112'; // Replace with your actual database ID
  late String documentId;
  bool isAdded = true;
  late RealtimeSubscription subscribtion;

  @override
  void initState() {
    super.initState();
    subscribe();
    loadFavorites();
  }

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;

    if (screenWidth <= 400) {
      crossAxisCount = 2;
    } else if (screenWidth >= 400 && screenWidth <= 600) {
      crossAxisCount = 2;
    } else if (screenWidth >= 600 && screenWidth <= 800) {
      crossAxisCount = 3;
    } else if (screenWidth >= 800) {
      crossAxisCount = 4;
    }

    return crossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                ), // Add some whitespace at the end
              ),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  mainAxisExtent: 300,
                ),
                // itemCount: widget.content.length + 1,

                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final Wallpaper wallpaper = widget.content[index];
                    final newImage = wallpaper.url;
                    if (index == widget.content.length) {
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
                              imageUrl: wallpaper.url,
                              imageId: wallpaper.id,
                            ),
                          ),
                        ).then((_) {
                          loadFavorites();
                        });
                      },
                      // onLongPress: () {
                      //   toggleFavorite(context, wallpaper.url, index);
                      // },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Stack(
                          children: [
                            ImageComponent(imagePath: newImage),
                            // if (checkIfInFavorites(newImage))
                            //   Container(
                            //     width: double.infinity,
                            //     height: double.infinity,
                            //     color: Colors.black54,
                            //     padding: const EdgeInsets.all(16.0),
                            //     child: const Text(
                            //       "Library",
                            //       style: TextStyle(
                            //         color: Colors.white,
                            //         fontSize: 16.0,
                            //         wordSpacing: 30.0,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   )
                            // else
                            //   const SizedBox(),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Center(
                                child: LikeButton(
                                  onTap: (isLiked) => onLikeButtonTap(
                                      isLiked, context, wallpaper.url, index),
                                  size: 42,
                                  likeBuilder: (bool isLiked) {
                                    bool isInFavorites =
                                        checkIfInFavorites(wallpaper.url);
                                    return ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(20000),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        color: Colors.black26,
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
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: widget.content.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                ), // Add some whitespace at the end
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> loadFavorites() async {
    try {
      var promise = await account.get();
      var email = promise.email;
      var name = promise.name;
      var listData = await databases.listDocuments(
        collectionId: '6490339aacca8d3aecf2',
        databaseId: '649033920793f53a7112',
        queries: [
          Query.equal('userEmail', email),
          Query.equal('userName', name),
          Query.limit(90),
        ],
      );

      setState(() {
        documents = listData.documents.map((document) {
          var data = document.data;
          documentId = document.$id;
          return DocumentData(
            email: data['userEmail'],
            name: data['userName'],
            imageUrl: data['url'],
            date: data['date'],
            isNSFW: data['isNSFW'],
          );
        }).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching favorites: $e');
      }
    }
  }

  bool checkIfInFavorites(image) {
    for (var document in documents) {
      if (document.imageUrl == image) {
        return true;
      }
    }
    return false;
  }

  Future<void> addToFavorites(String item) async {
    var promise = await account.get();
    try {
      final now = DateTime.now();
      final formattedDate =
          now.toIso8601String(); // Format the date as an ISO 8601 string
      final document = await databases.createDocument(
        collectionId: collectionId,
        data: {
          'url': item,
          'userEmail': promise.email,
          'userName': promise.name,
          'date': formattedDate,
          'isNSFW': item.contains("slxftlarogkbsdtwepdn.supabase.co"),
        },
        databaseId: databaseId,
        documentId: uniqueId,
      );
      if (kDebugMode) {
        print('Document added with ID: ${document.$databaseId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding document: $e');
      }
    }
  }

  Future<void> removeFromFavorites(String item) async {
    var promise = await account.get();
    String documentId = '';

    try {
      var listData = await databases.listDocuments(
          collectionId: collectionId,
          databaseId: databaseId,
          queries: [
            Query.equal('userName', promise.name),
            Query.equal('userEmail', promise.email),
            Query.limit(90),
          ]);

      for (var document in listData.documents) {
        var data = document.data;
        if (data['url'] == item &&
            data['userEmail'] == promise.email &&
            data['userName'] == promise.name) {
          documentId = document.$id;
        }
      }

      await databases.deleteDocument(
        collectionId: collectionId,
        documentId: documentId,
        databaseId: databaseId,
      );
      if (kDebugMode) {
        print('Document removed with ID: $documentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing document: $e');
      }
    }
  }

  void showRemoveDialog(BuildContext context, String image, int index) {
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
                removeFromFavorites(image).then((_) => loadFavorites());
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
      showRemoveDialog(context, image, index);
    } else {
      await addToFavorites(image);
      loadFavorites();
    }
    return true; // Return true to indicate that the like state has been changed
  }

  Future<bool?> onLikeButtonTap(bool isLiked, context, image, index) async {
    // Check if the image is in favorites
    bool isInFavorites = checkIfInFavorites(image);

    if (isInFavorites) {
      // If it's in favorites, show the remove dialog and return false
      showRemoveDialog(context, image, index);
      return false;
    } else {
      // If it's not in favorites, add it and return true
      await addToFavorites(image);
      loadFavorites();
      return true;
    }
  }

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
      // documents = List<DocumentData>.from(payload['imageUrl']);
      // listData.documents.map((document) {
      //   var data = document.data;
      //   documentId = document.$id;
      //   return DocumentData(
      //     email: data['userEmail'],
      //     name: data['userName'],
      //     imageUrl: data['url'],
      //     date: data['date'],
      //   );
      // }).toList();
      loadFavorites();
    });
  }

  void handleDocumentUpdate(Map<String, dynamic> payload) {
    setState(() {
      // documents = List<DocumentData>.from(payload['imageUrl']);
      loadFavorites();
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscribtion.close();
  }
}
