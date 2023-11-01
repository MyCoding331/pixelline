// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:pixelline/api_service.dart';
import 'package:pixelline/model/appwrite_sevices.dart';
import 'package:pixelline/model/wallpaper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CardPage extends StatefulWidget {
  final int randomOffset;
  bool isLoadingImages;
  CardPage({
    required this.randomOffset,
    required this.isLoadingImages,
    Key? key,
  }) : super(key: key);

  @override
  _ImageCaedState createState() => _ImageCaedState();
}

class _ImageCaedState extends State<CardPage> {
  String imageFiles = ''; // Store the list of image files
  String newData = ''; // Store the list of image files
  int imageId = 0; // Store the list of image files
  String imageUrl = '';
  int fileCount = 0;
  int randomCount = 0;
  bool url = false;
  bool _isMounted = false;
  List<DocumentData> documents = [];
  late String documentId;
  late RealtimeSubscription subscribtion;
  final String collectionId = '6490339aacca8d3aecf2'; // Replace with your actual collection ID
  final String databaseId = '649033920793f53a7112'; // Replace with your actual database ID

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    subscribe();
    if (imageUrl.isEmpty) {
      loadImages();
      loadFavorites();
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    subscribtion.close();
    super.dispose();
  }

  Future<void> loadImages() async {
    int count = widget.randomOffset;
    setState(() {
      randomCount = count;
    });
    try {
      if (!_isMounted) return;
      setState(() {
        widget.isLoadingImages = true;
      });
      final List<FileObject> objects = await superbase.storage.from('images').list(
            path: 'Jpg/part-1',
            searchOptions: SearchOptions(
              limit: 1,
              offset: randomCount,
            ),
          );
      if (_isMounted && objects.isNotEmpty) {
        setState(() {
          final data = objects.map((file) => file);
          imageFiles = data.first.name;
        });
        String image = superbase.storage.from('images').getPublicUrl('Jpg/part-1/$imageFiles');
        setState(() {
          imageUrl = image;
        });
      } else {
        if (kDebugMode) {
          print('No FileObject found.');
        }
      }
    } catch (e) {
      if (_isMounted) {
        if (kDebugMode) {
          print('Failed to fetch images: $e');
        }
      }
    }
  }

  Future<void> loadFavorites() async {
    try {
      var promise = await account.get();
      var email = promise.email;
      var name = promise.name;
      var listData = await database.listDocuments(
        collectionId: '6490339aacca8d3aecf2',
        databaseId: '649033920793f53a7112',
        queries: [
          Query.equal('userEmail', email),
          Query.equal('userName', name),
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

  Future<bool?> onLikeButtonTap(bool isLiked, context, image) async {
    bool isInFavorites = checkIfInFavorites(image);

    if (isInFavorites) {
      showRemoveDialog(
        context,
        image,
      );
      return false;
    } else {
      await addToFavorites(image);
      loadFavorites();
      return true;
    }
  }

  Future<void> addToFavorites(String item) async {
    var promise = await account.get();
    try {
      final now = DateTime.now();
      final formattedDate = now.toIso8601String();
      final document = await database.createDocument(
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
      var listData = await database.listDocuments(
        collectionId: collectionId,
        databaseId: databaseId,
      );

      for (var document in listData.documents) {
        var data = document.data;
        if (data['url'] == item && data['userEmail'] == promise.email && data['userName'] == promise.name) {
          documentId = document.$id;
        }
      }

      await database.deleteDocument(
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

  void showRemoveDialog(BuildContext context, String image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          actionsPadding: const EdgeInsets.all(10),
          title: const Text("Warning..!!", style: TextStyle(color: Colors.black)),
          content: const Text("Are you sure you want to remove this item?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 16.0)),
            ),
            ElevatedButton(
              onPressed: () {
                removeFromFavorites(image).then((_) => loadFavorites());
                Navigator.of(context).pop(true);
              },
              child: const Text("Remove", style: TextStyle(fontSize: 16.0)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagechanger = url
        ? 'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aHVtYW58ZW58MHx8MHx8fDA%3D&w=1000&q=80'
        : imageUrl;

    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            ImageComponent(imagePath: imagechanger),
            Positioned(
              bottom: 5,
              right: 5,
              child: LikeButton(
                onTap: (isLiked) => onLikeButtonTap(isLiked, context, imagechanger),
                size: 45,
                likeBuilder: (bool isLiked) {
                  bool isInFavorites = checkIfInFavorites(imagechanger);
                  return Icon(
                    Icons.favorite,
                    color: isInFavorites ? Colors.red : Colors.white,
                    size: 25,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void subscribe() {
    subscribtion = realtime.subscribe(['documents']);
    subscribtion.stream.listen((event) {
      final eventType = event.events;
      final payload = event.payload;

      if (eventType.contains('database.*.collections.*.documents.*.create')) {
        handleDocumentCreation(payload);
      } else if (eventType.contains('database.*.collections.*.documents.*.delete')) {
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
}
