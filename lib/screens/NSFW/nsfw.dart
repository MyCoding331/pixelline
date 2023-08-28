// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/model/appwrite_sevices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import './card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NSFW extends StatefulWidget {
  const NSFW({Key? key}) : super(key: key);

  @override
  _NSFWImages createState() => _NSFWImages();
}

class _NSFWImages extends State<NSFW> {
  int batchSize = 25;
  final ScrollController _scrollController = ScrollController();
  int page = 1;
  List<Map<String, dynamic>> cards = [];
  bool isLoading = false;
  int fileCount = 0;
  bool isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _loadFileCount();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadFileCount() async {
    int count = await retrieveFileCount();
    if (count <= 16471) {
      setState(() {
        fileCount = count;
        cards = []; // Clear the existing cards list
      });
      _loadCards();
    } else {
      count = await getFileCount();
      await storeFileCount(count);
      setState(() {
        fileCount = count;
        cards = []; // Clear the existing cards list
      });
      _loadCards();
    }
  }

  Future<int> getFileCount() async {
    try {
      final bucket = superbase.storage.from('images');
      final response = await bucket.list(
        path: 'Jpg/part-1',
        searchOptions: const SearchOptions(limit: 150000),
      );
      List<FileObject> files = response;
      int count = files.length;
      if (kDebugMode) {
        print('my file count is $count');
      }
      return count;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch files from folder: $e');
      }
      return Random().nextInt(16000);
    }
  }

  Future<void> storeFileCount(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fileCount', count);
  }

  Future<int> retrieveFileCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('fileCount') ?? 0;
    return count;
  }

  int randomOffset(int count) {
    if (count > 0) {
      return Random().nextInt(count);
    } else {
      return Random().nextInt(16000);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchMoreCards();
    }
  }

  void fetchMoreCards() {
    if (isLoading || isLoadingImages) {
      return;
    }

    // Check if the file count is greater than the current number of cards
    if (fileCount > cards.length) {
      setState(() {
        isLoading = true;
      });

      _loadCards();
    }
  }

  void _loadCards() async {
    try {
      final List<Map<String, dynamic>> newCards = List.generate(20, (index) {
        final randomOffsetValue = randomOffset(fileCount);
        return {
          'key': (page - 1) * 20 + index,
          'randomOffset': randomOffsetValue,
        };
      });

      setState(() {
        cards.addAll(newCards);
        page++;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch images: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Timer? _loadingTimer;

  // Method to cancel the loading timer
  void _cancelLoadingImages() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cancelLoadingImages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 320,
            ),
            controller: _scrollController,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final randomOffsetValue = cards[index]['randomOffset'];
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: CardPage(
                  randomOffset: randomOffsetValue,
                  isLoadingImages: isLoadingImages,
                ),
              );
            },
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
