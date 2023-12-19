import 'package:flutter/material.dart';
import 'package:pixelline/services/types/wallpaper.dart';

class WallpaperProvider with ChangeNotifier {
  List<Wallpaper> wallpaperList = [];

  storeWallpaper(val) {
    wallpaperList.addAll(val);
    notifyListeners();
  }
}
