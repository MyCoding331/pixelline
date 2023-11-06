import 'package:flutter/material.dart';
import 'components/random_wallpaper_screen_body.dart';

class RandomWallpaperScreen extends StatelessWidget {
  const RandomWallpaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RandomWallpaperScreenBody(),
    );
  }
}
