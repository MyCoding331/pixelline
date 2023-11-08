// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixelline/services/Appwrite/appwrite_sevices.dart';
import 'package:pixelline/services/GlobalContext/global_context.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperStorage<T> {
  final String storageKey;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final SharedPreferences prefs;
  String collectionId = dotenv.env['APPWRITE_COLLECTION_ID']!;
  String databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  String bucketId = dotenv.env['APPWRITE_BUCKET_ID']!;

  WallpaperStorage({
    required this.storageKey,
    required this.fromJson,
    required this.toJson,
    required this.prefs,
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

  Future<void> backupData(String key, List<T> dataList) async {
    if (kDebugMode) {
      print('Backing up data...');
    }
    final email = await getEmail();
    final name = await getName();
    final externalDir = await getExternalStorageDirectory();
    final filePath = '${externalDir!.path}/$email-$key.json';
    final file = File(filePath);
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
          fileId: uniqueId,
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
          await storage.deleteFile(
            bucketId: bucketId,
            fileId: documentId,
          );
          await storage.createFile(
            file: fileMultipartFile,
            bucketId: bucketId,
            fileId: documentId,
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
      if (data is Wallpaper && data.id == dataId) {
        return true;
      }
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

randomStringGenerataor(int length) {
  final random = Random();
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String result = '';
  for (int i = 0; i < length; i++) {
    result += chars[random.nextInt(chars.length)];
  }

  return result;
}

randomIntGenrator() {
  Random random = Random();

  // Generate a random 6-digit integer
  int min = 100000; // Minimum 6-digit integer (100000)
  int max = 999999; // Maximum 6-digit integer (999999)
  int randomSixDigitNumber = min + random.nextInt(max - min);
  if (kDebugMode) {
    print('Random 6-digit number: $randomSixDigitNumber');
  }
  return randomSixDigitNumber;
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      behavior: SnackBarBehavior.floating,
      // action: SnackBarAction(
      //   label: 'Undo',
      //   textColor: Colors.white,
      //   onPressed: () {
      //     // Implement your undo logic here
      //   },
      // ),
    ),
  );
}

final BuildContext globalContext = GlobalContext.navigatorKey.currentContext!;
final height = MediaQuery.of(globalContext).size.height;
final width = MediaQuery.of(globalContext).size.width;

// ignore: must_be_immutable
class CircularIndicator extends StatelessWidget {
  Color color;
  CircularIndicator({super.key, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 3.0,
      ),
    );
  }
}
