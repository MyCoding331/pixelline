import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/components/ImageComponent/image_component.dart';
import 'package:pixelline/screens/DetailScreen/detail_screen.dart';
import 'package:pixelline/services/types/wallpaper.dart';

class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.filteredFavorites,
    required ScrollController scrollController,
  }) : _scrollController = scrollController;

  final List<Wallpaper> filteredFavorites;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      reverseDuration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeInExpo,
      switchOutCurve: Curves.easeOutExpo,
      child: filteredFavorites.isNotEmpty
          ? CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    mainAxisExtent: 300,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final favorite = filteredFavorites[index];

                      if (index == filteredFavorites.length) {
                        return Container(
                          color: Colors.transparent,
                          child: const CupertinoActivityIndicator(radius: 20),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                imageUrl: favorite.url,
                                wallpaper: favorite,
                                imageId: favorite.id
                                    .replaceAll('https://hdqwalls.com', ''),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: ImageComponent(imagePath: favorite.url),
                        ),
                      );
                    },
                    childCount: filteredFavorites
                        .length, // +1 for the loading indicator
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                  ), // Add some whitespace at the end
                ),
              ],
            )
          : const Center(
              child: Text(
                "No Favorites Found",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 29,
                ),
              ),
            ),
    );
  }
}
