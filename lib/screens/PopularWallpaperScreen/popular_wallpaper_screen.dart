import 'package:flutter/material.dart';
import 'components/popular_wallpaper_screen_body.dart';

class PopularWallpaperScreen extends StatelessWidget {
  const PopularWallpaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PopularWallpaperScreenBody(),
    );
  }
}
