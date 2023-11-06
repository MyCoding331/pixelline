// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:pixelline/services/appwrite_sevices.dart';
import 'package:pixelline/screens/LatestWallpaperScreen/latest_wallpaper_screen.dart';
import 'package:pixelline/screens/PopularWallpaperScreen/popular_wallpaper_screen.dart';
import 'package:pixelline/screens/RandomWallpaperScreen/random_wallpaper_screen.dart';

class TabBarContainer extends StatefulWidget {
  const TabBarContainer({
    Key? key,
  }) : super(key: key);

  @override
  _TabBarContainerState createState() => _TabBarContainerState();
}

class _TabBarContainerState extends State<TabBarContainer> {
  int _selectedIndex = 0;
  bool isSubscription = false;

  final List<Widget> _pages = [
    const LatestWallpaperScreen(),
    const PopularWallpaperScreen(),
    const RandomWallpaperScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the pages list based on widget.isSubscription
    // getSubscription().then((value) => _updatePages());
  }

  Future<void> getSubscription() async {
    try {
      final promise = await account.get();
      final email = promise.email;
      final name = promise.name;
      final data = await database.listDocuments(
        databaseId: '64c5fbb3ec64e7ac95a2',
        collectionId: '64c5fbbd4ea89a9c47a7',
        queries: [
          Query.equal('userEmail', email),
          Query.equal('userName', name),
        ],
      );
      final newData = data.documents.map((e) => e.data['isSubscribed']);
      if (kDebugMode) {
        print('newData = $newData');
      }

      // Check if at least one value in newData is true
      final isSubscribed = newData.contains(true);

      setState(() {
        isSubscription = isSubscribed;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          bottom: 60,
          right: 10,
        ),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          heroTag: 'float',
          onPressed: _openMenu,
          backgroundColor: Colors.black,
          child: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTab(0, Icons.new_releases, 'Latest'),
              _buildTab(1, Icons.local_fire_department, 'Popular'),
              _buildTab(2, Icons.shuffle, 'Random'),
              if (isSubscription)
                _buildTab(3, Icons.privacy_tip_outlined, 'NSFW'),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        // Handle selected option here
        if (kDebugMode) {
          print('Selected option: $value');
        }
      }
    });
  }

  Widget _buildTab(int index, IconData icon, String title) {
    final isSelected = index == _selectedIndex;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          Navigator.pop(context,
              title); // Close the bottom sheet and pass the selected title
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
