import 'package:flutter/material.dart';
import 'components/latest_wallpaper_screen_body.dart';

class LatestWallpaperScreen extends StatelessWidget {
  const LatestWallpaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LatestWallpaperScreenBody(),
    );
  }
}
