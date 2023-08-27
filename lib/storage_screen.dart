import 'package:appwrite/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/detail_screen.dart';
import 'package:pixelline/model/appwrite_sevices.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageState();
}

class _StorageState extends State<StorageScreen> {
  List<File> storageArray = [];
  @override
  void initState() {
    super.initState();

    loadFiles();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadFiles() async {
    final promise = storage.listFiles(bucketId: '64a58ef77f24bece3e41');

    promise.then((response) {
      if (kDebugMode) {
        print(response.files);
        setState(() {
          storageArray = response.files;
        });
      }
    }).catchError((error) {
      if (kDebugMode) {
        print(error.response);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Favorites Screen'),
      // ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 2000),
            reverseDuration: const Duration(milliseconds: 1000),
            switchInCurve: Curves.easeInExpo,
            switchOutCurve: Curves.easeOutExpo,
            child: storageArray.isNotEmpty
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      mainAxisExtent: 300,
                    ),
                    itemCount: storageArray.length,
                    itemBuilder: (context, index) {
                      final favorite = storageArray[index];
                      if (index == storageArray.length) {
                        return Container(
                          color: Colors
                              .transparent, // Use a transparent color for the container
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              CupertinoActivityIndicator(
                                radius: 20,
                              ),
                            ],
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageDetailsScreen(
                                imageUrl: favorite.name,
                              ),
                            ),
                          ).then((_) => loadFiles());
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Text(favorite.name),
                        ),
                        // ImageComponent(imagePath: favorite.imageUrl)),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      "No Favorites Found",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                      ),
                    ),
                  ),
          ),
          // if (isLoading)
          //   Container(
          //     color: Colors.white,
          //     child: const Center(
          //       child: CircularProgressIndicator(),
          //     ),
          //   ),
          // Positioned(
          //   bottom: 20,
          //   right: 20,
          //   child: PopupMenuButton<SortOption>(
          //     position: PopupMenuPosition.under,
          //     onSelected: (option) {
          //       // Call the sort method based on the selected option
          //       sortFavorites(option);
          //     },
          //     itemBuilder: (BuildContext context) =>
          //         <PopupMenuEntry<SortOption>>[
          //       const PopupMenuItem<SortOption>(
          //         value: SortOption.newest,
          //         child: Text('Newest'),
          //       ),
          //       const PopupMenuItem<SortOption>(
          //         value: SortOption.oldest,
          //         child: Text('Oldest'),
          //       ),
          //     ],
          //   ),
          // ),
          // Positioned(
          //   width: 110,
          //   height: 45,
          //   bottom: 30,
          //   right: 30,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(29),
          //     child: TextButton(
          //       style: ButtonStyle(
          //         backgroundColor: MaterialStateProperty.resolveWith<Color>(
          //           (Set<MaterialState> states) {
          //             if (states.contains(MaterialState.pressed)) {
          //               return const Color.fromARGB(
          //                   255, 2, 78, 141); // Color when button is pressed
          //             } else if (states.contains(MaterialState.hovered)) {
          //               return const Color.fromARGB(
          //                   255, 71, 160, 233); // Color when button is hovered
          //             } else {
          //               return Colors.black; // Default color
          //             }
          //           },
          //         ),
          //       ),
          //       // splashColor: Colors.black,
          //       onPressed: _openMenu,

          //       child: const Padding(
          //         padding: EdgeInsets.all(8.0),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceAround,
          //           children: [
          //             Icon(
          //               Icons.sort,
          //               color: Colors.white,
          //             ),
          //             Text(
          //               'sort',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 15,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      // floatingActionButton: ElevatedButton(
      //   style: ButtonStyle(
      //     backgroundColor: MaterialStateProperty.resolveWith<Color>(
      //       (Set<MaterialState> states) {
      //         if (states.contains(MaterialState.pressed)) {
      //           return const Color.fromARGB(
      //               255, 2, 78, 141); // Color when button is pressed
      //         } else if (states.contains(MaterialState.hovered)) {
      //           return const Color.fromARGB(
      //               255, 71, 160, 233); // Color when button is hovered
      //         } else {
      //           return Colors.black; // Default color
      //         }
      //       },
      //     ),
      //   ),
      //   // splashColor: Colors.black,
      //   onPressed: _openMenu,

      //   child: const Row(
      //     children: [
      //       Icon(Icons.sort),
      //       Text('sort'),
      //     ],
      //   ),
      // ),
    );
  }
}
