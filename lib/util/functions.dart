// ignore_for_file: use_build_context_synchronously

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pixelline/services/Api/api_service.dart';
import 'package:pixelline/services/Appwrite/appwrite_sevices.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'package:pixelline/util/util.dart';
import 'package:pixelline/wallpaper_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkUserSession() async {
  try {
    // Check if the user session exists
    final res = await account.get();
    final loc = await local.get();
    if (kDebugMode) {
      print(' country is ${loc.country}');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Update the Appwrite document with the new NSFW status
    await prefs.setString(
      'userId',
      res.$id,
    );
    await prefs.setString(
      'country',
      loc.country,
    );
    await prefs.setString(
      'ip',
      loc.ip,
    );

    return true;
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
    return false;
  }
}

Future<void> setUserDetails() async {
  final prefs = await SharedPreferences.getInstance();
  final promise = await account.get();
  await prefs.setString('userEmail', promise.email);
  await prefs.setString('userName', promise.name);
  if (kDebugMode) {
    print('userDetails has been set sucessfully');
  }
}

Future<void> userSignUp(
    {required String email,
    required String password,
    required String name}) async {
  final user = await account.create(
    userId: uniqueId,
    email: email,
    password: password,
    name: name,
  );

  if (kDebugMode) {
    print("User created with ID: ${user.$id}");
  }

  await database.createDocument(
    databaseId: databaseId,
    collectionId: collectionId,
    documentId: uniqueId,
    data: {
      "userId": uniqueId,
      'email': email,
      'password': password,
      'name': name,
    },
  );
}

Future<void> userLogin(
    {required String email, required String password}) async {
  await account.createEmailSession(email: email, password: password);
  showSnackBar(globalContext, 'Login successful!');
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString('userPassword', password);
  await Navigator.pushReplacement(
    globalContext,
    MaterialPageRoute(
      builder: (BuildContext globalContext) => const WallpaperScreen(),
    ),
  );
}

Future<List<Wallpaper>> commonFetch(
    APIService apiService, int? pageNumber) async {
  final List<Wallpaper> newWallpapers =
      await apiService.fetchWallpapers(pageNumber ?? 1);
  return newWallpapers;
}

Future<List<Wallpaper>> loadFavs(
    {required WallpaperStorage<Wallpaper> wallpaperStorage}) async {
  final jsonStringList = await wallpaperStorage.getDataList();

  await wallpaperStorage.restoreData();
  return jsonStringList;
}

void realtimeUpdate({
  required RealtimeSubscription subscribtion,
  required Function() loadFavorites,
}) {
  subscribtion = realtime.subscribe(['documents']);
  subscribtion.stream.listen((event) {
    final eventType = event.events;

    if (eventType.contains('databases.*.collections.*.documents.*.create')) {
      loadFavorites();
    } else if (eventType
        .contains('databases.*.collections.*.documents.*.delete')) {
      loadFavorites();
    }
  });
}

Future<bool> localAuthFunction(
    bool authenticated, LocalAuthentication localAuthentication) async {
  authenticated = await localAuthentication.authenticate(
    localizedReason: 'Authenticate To Access The App', // Displayed to user
    options: const AuthenticationOptions(
      biometricOnly: false,
      useErrorDialogs: true,
      stickyAuth: true,
    ),
  );
  return authenticated;
}

Future<void> updateUserDetails(
    String updatename, String updatephoneNumber) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final password = prefs.getString('userPassword');
    updatename != '' ? await account.updateName(name: updatename) : null;
    updatephoneNumber != ''
        ? await account.updatePhone(
            phone: '+91$updatephoneNumber', password: password!)
        : null;

    if (kDebugMode) {
      print(' update to $updatephoneNumber successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Authentication failed: $e');
    }
    showDialog(
      context: globalContext,
      builder: (context) => AlertDialog(
        title: const Text('Name Update Failed'),
        content: const Text('Please check your name format'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
