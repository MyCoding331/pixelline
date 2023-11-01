// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:pixelline/model/wallpaper.dart';
import 'package:flutter/material.dart';

class APIService {
  String params;
  final String baseUrl = 'https://hqwalls.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIService({required this.params});

  Future<List<Wallpaper>> fetchWallpapers(int pageNo) async {
    final String url = '$baseUrl/$params/$pageNo';

    final response = await http.get(Uri.parse(url), headers: imgHeaders);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<Wallpaper> wallpapers = data.map((item) => Wallpaper.fromJson(item)).toList();
      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }

  Future<List<Wallpaper>> similarFetch(id) async {
    final String url = '$baseUrl/$params$id';

    final response = await http.get(Uri.parse(url), headers: imgHeaders);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<Wallpaper> wallpapers = data.map((item) => Wallpaper.fromJson(item)).toList();
      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class ImageComponent extends StatelessWidget {
  final String imagePath;

  const ImageComponent({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newImage = imagePath.replaceAll("wallpapers/thumb", "download").replaceAll(".jpg", "-1080x1920.jpg");
    // final newPlaceHolderImage = imagePath
    //     .replaceAll("wallpapers/thumb", "download")
    //     .replaceAll(".jpg", "-320x240.jpg");
    final uniqueTag = UniqueKey().toString();
    return Hero(
        tag: uniqueTag,
        child: SizedBox(
          height: 320.0,
          child: CachedNetworkImage(
            imageUrl: newImage,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            // color: Colors.black38,
            placeholderFadeInDuration: const Duration(milliseconds: 700),
            useOldImageOnUrlChange: true,
            placeholder: (context, url) => Center(
              child: CachedNetworkImage(
                imageUrl:
                    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aHVtYW58ZW58MHx8MHx8fDA%3D&w=1000&q=80',
                fit: BoxFit.cover,
                height: 320.0,
                width: double.infinity,
                useOldImageOnUrlChange: true,
                placeholderFadeInDuration: const Duration(milliseconds: 700),
                color: Colors.black38,
                progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Center(
              child: CachedNetworkImage(
                imageUrl:
                    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aHVtYW58ZW58MHx8MHx8fDA%3D&w=1000&q=80',
                fit: BoxFit.cover,
                height: 320.0,
                width: double.infinity,
                useOldImageOnUrlChange: true,
                placeholderFadeInDuration: const Duration(milliseconds: 700),
                color: Colors.black38,
                progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
