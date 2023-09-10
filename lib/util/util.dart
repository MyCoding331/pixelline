// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pixelline/model/appwrite_sevices.dart';
import 'package:pixelline/model/wallpaper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperStorage<T> {
  final String storageKey;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final SharedPreferences prefs;
  final String collectionId;
  final String databaseId;
  final String bucketId;

  WallpaperStorage({
    required this.storageKey,
    required this.fromJson,
    required this.toJson,
    required this.prefs,
    this.collectionId = '64fd7c137cfcf4d53c1d',
    this.databaseId = '649033920793f53a7112',
    this.bucketId = '64fd7bfeb5e437766a60',
  });
  Future<String?> getEmail() async {
    return prefs.getString('userEmail');
  }

  Future<String?> getName() async {
    return prefs.getString('userName');
  }

  Future<void> storeData(T data, context) async {
    if (kDebugMode) {
      print('Storing data...');
    }
    final dataList = await getDataList();

    dataList.add(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added Successfully In Favorites'),
        duration: Duration(seconds: 2),
      ),
    );
    // await prefs.setStringList(
    //     storageKey, dataList.map((e) => jsonEncode(toJson(e))).toList());

    await backupData(storageKey, dataList);
    if (kDebugMode) {
      print('Data stored.');
    }
  }

  Future<List<T>> getDataList() async {
    if (kDebugMode) {
      print('Getting data list...');
    }

    final email = await getEmail();
    final externalDir = await getExternalStorageDirectory();
    final filePath = '${externalDir!.path}/$email-$storageKey.json';
    final file = File(filePath);

    if (await file.exists()) {
      final dataAsString = await file.readAsString();
      final decodedData = jsonDecode(dataAsString) as List<dynamic>;

      if (kDebugMode) {
        print('Data retrieved.');
      }
      return decodedData.map((json) => fromJson(json)).cast<T>().toList();
    }

    // Data doesn't exist, return an empty list
    return [];
  }

// Backup data in version 1.0.2
  Future<void> backupData(String key, List<T> dataList) async {
    if (kDebugMode) {
      print('Backing up data...');
    }
    // final externalDir =externalDirectory.then((value) => value!.path);
    final email = await getEmail();
    final name = await getName();
    final externalDir = await getExternalStorageDirectory();
    final filePath = '${externalDir!.path}/$email-$key.json';
    final file = File(filePath);
    // print(email);
    // print(name);
    if (!await file.exists()) {
      await file.create();
    }

    final fileData = jsonEncode(dataList.map((data) => toJson(data)).toList());

    await file.writeAsString(fileData);

    try {
      final fileMultipartFile = InputFile.fromPath(
        path: file.path,
        filename: '$email-$key.json',
        contentType: 'application/json',
      );

      final documentList = await database.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('name', name),
          Query.equal('email', email),
          Query.equal('type', key),
        ],
      );

      if (documentList.documents.isEmpty) {
        final fileDetails = await storage.createFile(
          file: fileMultipartFile,
          bucketId: bucketId,
          fileId: uniqueId, // Generate a unique ID
        );

        await database.createDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: uniqueId,
          data: {
            'name': name,
            'email': email,
            'type': key,
            'fileId': fileDetails.$id,
          },
        );

        if (kDebugMode) {
          print('File uploaded with file ID: ${fileDetails.$id}');
        }
      } else {
        final documentIds =
            documentList.documents.map((e) => e.data['fileId']).toList();

        for (final documentId in documentIds) {
          // await storage.updateFile(
          //   bucketId: '64f3a92c7ab086900e74',
          //   fileId: documentId,
          // );

          await storage.deleteFile(
            bucketId: bucketId,
            fileId: documentId,
          );
          await storage.createFile(
            file: fileMultipartFile,
            bucketId: bucketId,
            fileId: documentId, // Generate a unique ID
          );

          if (kDebugMode) {
            print('File updated with file ID: $documentId');
          }
        }
      }
      if (kDebugMode) {
        print('Data backed up successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error backing up data: $e');
      }
      // Handle the error as needed (e.g., log, display an error message).
    }
  }

  Future<List<T>> restoreData() async {
    try {
      final email = await getEmail();
      final name = await getName();
      final externalDir = await getExternalStorageDirectory();
      final filePath = '${externalDir!.path}/$email-$storageKey.json';
      final file = File(filePath);

      if (!await file.exists()) {
        final documentQuery = await database.listDocuments(
          databaseId: databaseId,
          collectionId: collectionId,
          queries: [
            Query.equal('name', name),
            Query.equal('email', email),
            Query.equal('type', storageKey),
          ],
        );
        if (documentQuery.documents.isNotEmpty) {
          final documentIds =
              documentQuery.documents.map((e) => e.$id).toList();

          for (final documentId in documentIds) {
            final document = await database.getDocument(
              databaseId: databaseId,
              collectionId: collectionId,
              documentId: documentId,
            );

            if (document.data['fileId'] != null) {
              final fileId = document.data['fileId'];
              final response = await storage.getFileDownload(
                bucketId: bucketId,
                fileId: fileId,
              );

              final file = File(filePath);
              await file.writeAsBytes(response);
              final dataAsString = await file.readAsString();
              final decodedData = jsonDecode(dataAsString) as List<dynamic>;
              return decodedData
                  .map((json) => fromJson(json))
                  .cast<T>()
                  .toList();
            }
          }
        } else {
          final dataList = await getDataList();
          await backupData(storageKey, dataList);
        }
      } else {
        final dataAsString = await file.readAsString();
        final decodedData = jsonDecode(dataAsString) as List<dynamic>;

        return decodedData.map((json) => fromJson(json)).cast<T>().toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring data: $e');
      }
    }

    return [];
  }

  Future<void> removeData(String dataId, BuildContext context) async {
    if (kDebugMode) {
      print('Removing data...');
    }

    final dataList = await getDataList();

    dataList.removeWhere((data) {
      // final item = fromJson(jsonDecode(data as String));
      if (data is Wallpaper && data.id == dataId) {
        return true;
      }
      // else if (data is Stars && data.id == dataId) {
      //   return true;
      // } else if (data is Channels && data.id == dataId) {
      //   return true;
      // }
      return false;
    });

    await prefs.setStringList(
        storageKey, dataList.map((e) => jsonEncode(toJson(e))).toList());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed Successfully From Favorites'),
        duration: Duration(seconds: 2),
      ),
    );
    await backupData(storageKey, dataList);

    if (kDebugMode) {
      print('Data removed.');
    }
  }
}

Future<void> insertRandomAds(List<Wallpaper> wallpapers) async {
  const int numAdsToInsert = 4; // You can adjust this as needed

  for (int i = 0; i < numAdsToInsert; i++) {
    final int randomIndex = Random()
        .nextInt(wallpapers.length + 1); // +1 to allow inserting at the end
    // final bool newBool = Random().nextBool();

    wallpapers.insert(
      randomIndex,
      Wallpaper(
        id: 'id$i',
        url: 'https://alterassumeaggravate.com',
      ),
    );
  }
}
