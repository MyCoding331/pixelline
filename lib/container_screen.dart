import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/model/pages.dart';
import 'api_service.dart';
import 'categories.dart';
import 'fav_screen.dart';
import 'model/wallpaper.dart';

class ViewContainer extends StatefulWidget {
  final String passedData;

  const ViewContainer({Key? key, required this.passedData}) : super(key: key);

  @override
  State<ViewContainer> createState() => _ContainerState();
}

class _ContainerState extends State<ViewContainer> {
  List<Wallpaper> wallpapers = [];
  late Future<List<Wallpaper>> futureWallpapers;
  List<Wallpaper> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];
  int pageIndex = 0;
  late APIService apiService =
      APIService(params: 'search/${widget.passedData}');

  @override
  void initState() {
    super.initState();
    // final APIService apiService = APIService(params: widget.passedData);
    futureWallpapers = apiService.fetchWallpapers(1);
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Wallpaper> newWallpapers =
          await apiService.fetchWallpapers(pageNumber);

      setState(() {
        wallpapers.addAll(newWallpapers);
        pageNumber++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Failed to load wallpapers: $e');
      }
    }
  }

  late String categTitle = widget.passedData.replaceAll("wall/", "");
  late String changeString = categTitle;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ViewContainer2(
        passedData: categTitle,
      ),
      ViewContainer3(
        passedData: categTitle,
      ),
      const FavScreen(),
      const Categories(),
    ];
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 30, // Set the color of the back button
        ),
        shadowColor: Colors.transparent,
        // actions: <Widget>[
        //   IconButton(
        //     icon: AnimatedCrossFade(
        //       firstChild: const Icon(Icons.search),
        //       secondChild: const Icon(Icons.close),
        //       crossFadeState: _isSearching
        //           ? CrossFadeState.showSecond
        //           : CrossFadeState.showFirst,
        //       duration: const Duration(milliseconds: 1000),
        //     ),
        //     // _isSearching
        //     //     ? const Icon(Icons.close, size: 30, color: Colors.black)
        //     //     : const Icon(Icons.search, size: 30, color: Colors.black),
        //     color: Colors.black,
        //     onPressed: () {
        //       // showSearch(context: context, delegate: CustomSearhDelegate());
        //       _toggleSearch();
        //     },
        //   )
        // ],
        title:
            //  _isSearching
            //     ? RawKeyboardListener(
            //         focusNode: FocusNode(),
            //         onKey: (RawKeyEvent event) {
            //           if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
            //             _search();
            //           }
            //         },
            //         child: TextField(
            //           controller: _searchController,
            //           onSubmitted: (_) => _search(),
            //           decoration: InputDecoration(
            //             hintText: 'Enter search term',
            //             filled: false,
            //             isCollapsed: true,
            //             hintStyle: TextStyle(
            //                 color: Colors.black.shade200,
            //                 fontWeight: FontWeight.w500,
            //                 fontSize: 18.0),

            //             border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(8.0),
            //               borderSide: BorderSide.none, // Remove the border
            //             ),
            //             contentPadding: const EdgeInsets.symmetric(
            //                 vertical: 16.0, horizontal: 16.0),
            //           ),
            //         ),
            //       )
            //     :
            Text(
          // textAlign: TextAlign.center,
          categTitle,
          // "faljpojfhfh",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavyBar(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        selectedIndex: pageIndex,
        onItemSelected: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        items: [
          BottomNavyBarItem(
            icon: Icon(
              pageIndex == 0 ? Icons.new_releases : Icons.new_releases_outlined,
              size: 30,
              color: pageIndex == 0 ? Colors.black : Colors.black,
            ),
            title: const Text('Latest'),
            activeColor: Colors.black,
          ),
          BottomNavyBarItem(
            icon: Icon(
              pageIndex == 1
                  ? Icons.local_fire_department
                  : Icons.local_fire_department_outlined,
              size: 30,
              color: pageIndex == 1 ? Colors.black : Colors.black,
            ),
            title: const Text('Popular'),
            activeColor: Colors.black,
          ),
          // BottomNavyBarItem(
          //   icon: Icon(
          //     pageIndex == 2 ? Icons.shuffle : Icons.shuffle_outlined,
          //     size: 30,
          //     color: pageIndex == 2 ? Colors.black : Colors.black,
          //   ),
          //   title: const Text('Random'),
          //   activeColor: Colors.black,
          // ),
          // BottomNavyBarItem(
          //   icon: Icon(
          //     pageIndex == 3 ? Icons.favorite : Icons.favorite_outlined,
          //     size: 30,
          //     color: pageIndex == 3 ? Colors.black : Colors.black,
          //   ),
          //   title: const Text('Favorites'),
          //   activeColor: Colors.black,
          // ),
          // BottomNavyBarItem(
          //   icon: Icon(
          //     pageIndex == 4 ? Icons.category : Icons.category_outlined,
          //     size: 30,
          //     color: pageIndex == 4 ? Colors.black : Colors.black,
          //   ),
          //   title: const Text('Categories'),
          //   activeColor: Colors.black,
          // ),
        ],
      ),
      body: Scaffold(
        body: Stack(
          children: [
            pages[pageIndex],
          ],
        ),
      ),
      // body: NotificationListener<ScrollNotification>(
      //   onNotification: _onScrollNotification,
      //   child: GridView.builder(
      //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //       crossAxisCount: 2,
      //       mainAxisSpacing: 6,
      //       crossAxisSpacing: 6,
      //       mainAxisExtent: 300,
      //     ),
      //     itemCount: wallpapers.length + 1,
      //     itemBuilder: (context, index) {
      //       if (index == wallpapers.length) {
      //         return Container(
      //           color: Colors
      //               .transparent, // Use a transparent color for the container
      //           child: const Stack(
      //             alignment: Alignment.center,
      //             children: [
      //               CupertinoActivityIndicator(
      //                 radius: 20,
      //               ),
      //             ],
      //           ),
      //         );
      //       }

      //       final Wallpaper wallpaper = wallpapers[index];
      //       final newImage = wallpaper.url
      //           .replaceAll("wallpapers/thumb", "download")
      //           .replaceAll(".jpg", "-1280x720.jpg");
      //       final newPlaceHolderImage = wallpaper.url
      //           .replaceAll("wallpapers/thumb", "download")
      //           .replaceAll(".jpg", "-320x240.jpg");

      //       return GestureDetector(
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) =>
      //                   ImageDetailsScreen(imageUrl: wallpaper.url),
      //             ),
      //           );
      //           (BuildContext context) {
      //             Navigator.pop(context, 'reload');
      //           };
      //         },
      //         onLongPress: () {
      //           toggleFavorite(wallpaper.url);
      //         },
      //         child: ClipRRect(
      //           borderRadius: BorderRadius.circular(12.0),
      //           child: Stack(children: [
      //             CachedNetworkImage(
      //               imageUrl: newImage,
      //               fit: BoxFit.cover,
      //               height: 500.0,

      //               // color: Colors.black38,
      //               placeholderFadeInDuration:
      //                   const Duration(milliseconds: 700),
      //               useOldImageOnUrlChange: true,
      //               placeholder: (context, url) => Center(
      //                 child: CachedNetworkImage(
      //                   imageUrl: newPlaceHolderImage,
      //                   fit: BoxFit.cover,
      //                   height: 500.0,
      //                   useOldImageOnUrlChange: true,
      //                   placeholderFadeInDuration:
      //                       const Duration(milliseconds: 700),
      //                   color: Colors.black38,
      //                 ),
      //               ),
      //               errorWidget: (context, url, error) =>
      //                   const Icon(Icons.error),
      //             ),
      //             if (favorites.contains(wallpaper.url))
      //               Container(
      //                 width: double.infinity,
      //                 height: double.infinity,
      //                 // decoration: const BoxDecoration(color: Colors.black54),
      //                 color: Colors.black54,
      //                 padding: const EdgeInsets.all(16.0),
      //                 child: const Text(
      //                   "Library",
      //                   style: TextStyle(
      //                       // backgroundColor: Colors.black,
      //                       color: Colors.black,
      //                       fontSize: 16.0,
      //                       wordSpacing: 30.0,
      //                       fontWeight: FontWeight.bold),
      //                 ),
      //               )
      //             else
      //               const Row()
      //           ]),
      //         ),
      //       );
      //     },
      //   ),
      // ),
    );
  }
}
