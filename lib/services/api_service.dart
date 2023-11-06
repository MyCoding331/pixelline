// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pixelline/services/wallpaper.dart';

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
      final List<Wallpaper> wallpapers =
          data.map((item) => Wallpaper.fromJson(item)).toList();
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
      final List<Wallpaper> wallpapers =
          data.map((item) => Wallpaper.fromJson(item)).toList();
      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}
