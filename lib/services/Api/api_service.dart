import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pixelline/services/types/wallpaper.dart';

class APIService {
  final String params;
  final String baseUrl;

  APIService({required this.params}) : baseUrl = dotenv.env['BASE_API_LINK']!;

  Future<List<Wallpaper>> fetchWallpapers(int pageNo) async {
    final String url = '$baseUrl/$params/$pageNo';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<Wallpaper> wallpapers =
          data.map((item) => Wallpaper.fromJson(item)).toList();
      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }

  Future<List<Wallpaper>?> similarFetch(id) async {
    final String url = '$baseUrl/$params$id';
    if (kDebugMode) {
      print('the url is $url');
    }
    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print('the data is ${response.body}');
    }
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
