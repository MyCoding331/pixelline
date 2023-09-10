// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/model/wallpaper.dart';
import 'appwrite_sevices.dart';

class FavoriteUtils extends StatefulWidget {
  final List<DocumentData> documents;
  final String image;

  const FavoriteUtils({
    required this.documents,
    required this.image,
    Key? key,
  }) : super(key: key);

  @override
  _FavoriteUtilsState createState() => _FavoriteUtilsState();
}

class _FavoriteUtilsState extends State<FavoriteUtils> {
  bool isFavorite = false;
  late String documentId;
  final String collectionId =
      '6490339aacca8d3aecf2'; // Replace with your actual collection ID
  final String databaseId =
      '649033920793f53a7112'; // Replace with your actual database ID
  @override
  void initState() {
    super.initState();
    checkIfInFavorites();
  }

  void checkIfInFavorites() {
    // Iterate through the list of documents and check if the image is present in any of them
    for (var document in widget.documents) {
      if (document.imageUrl == widget.image) {
        setState(() {
          isFavorite = true;
        });
        return;
      }
    }
    setState(() {
      isFavorite = false;
    });
  }

  void toggleFavorite() async {
    setState(() {
      if (isFavorite) {
        removeFromFavorites();
        if (kDebugMode) {
          print("Removed from favorites");
        }
      } else {
        addToFavorites();
        if (kDebugMode) {
          print("Added to favorites");
        }
      }
      isFavorite = !isFavorite;
    });
  }

  void addToFavorites() async {
    var promise = await account.get();
    try {
      final document = await database.createDocument(
        collectionId: collectionId,
        data: {
          'url': widget.image,
          'userEmail': promise.email,
          'userName': promise.name,
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

  void removeFromFavorites() async {
    try {
      for (var document in widget.documents) {
        if (document.imageUrl == widget.image) {
          await database.deleteDocument(
            collectionId: collectionId,
            documentId: documentId,
            databaseId: databaseId,
          );
          if (kDebugMode) {
            print('Document removed with ID: $documentId');
          }
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing document: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
