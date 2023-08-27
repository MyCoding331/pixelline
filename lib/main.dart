// import 'package:appwrite/appwrite.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixelline/model/Auth/auth.dart';
import 'package:pixelline/model/Auth/locaAuth.dart';
import 'model/appwrite_sevices.dart';

import 'wallpaper_screen.dart';
import 'model/Auth/appwrite_auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Permission.storage.request();
  Permission.manageExternalStorage.request();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  runApp(const WallpaperApp());
}

class WallpaperApp extends StatefulWidget {
  const WallpaperApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WallpaperAppState createState() => _WallpaperAppState();
}

class _WallpaperAppState extends State<WallpaperApp> {
  Future<bool>? _userSessionFuture;
  Future<bool>? islockedEnabled;
  bool isLocked = false;

  @override
  void initState() {
    super.initState();
    _userSessionFuture = checkUserSession();
    checkIsLocked();
  }

  MaterialColor createMaterialColor(Color color) {
    Map<int, Color> swatch = {
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color.withOpacity(0.6),
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.8),
      800: color.withOpacity(0.9),
      900: color.withOpacity(1.0),
    };
    return MaterialColor(color.value, swatch);
  }

  void checkIsLocked() async {
    try {
      // Get the user preferences
      var prefs = await account.getPrefs();

      // Update the isNSFWEnabled state based on the user preferences
      setState(() {
        isLocked = prefs.data['isLocked'] ?? false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user preferences: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixelline',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Colors.black),
        fontFamily: 'garamond',
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          backgroundColor: Colors.black,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _userSessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking the user session
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.hasError) {
              // Handle any errors that occurred while checking the user session
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            } else {
              // User session exists, navigate to the home screen
              if (snapshot.data == true) {
                if (kDebugMode) {
                  print(snapshot.data);
                }
                if (isLocked) {
                  return LocalAuth();
                } else {
                  return const WallpaperScreen();
                }
              }
              // User session does not exist, navigate to the login screen
              else {
                if (kDebugMode) {
                  print(snapshot.data);
                }
                return const AuthPage();
                // const WallpaperScreen();
              }
            }
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> checkUserSession() async {
    try {
      // Check if the user session exists
      await account.get();

      return true;
    } catch (e) {
      // Handle any errors that occurred while checking the user session
      if (kDebugMode) {
        print('Error: $e');
      }
      return false;
    }
  }
}
