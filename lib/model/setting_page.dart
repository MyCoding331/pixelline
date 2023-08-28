// ignore_for_file: use_build_context_synchronously

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/model/appwrite_sevices.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late String name;
  String updatename = '';
  late String email;
  String updateemail = '';
  late String phoneNumber;
  String updatephoneNumber = '';
  bool isLoading = true;
  bool isSubscribed = false;
  late bool isTextFieldEnabled;
  Uint8List? avatarImage;
  bool isNSFWEnabled = false;
  bool isLocked = false;
  bool isNSFWToggled = false; // New variable to track NSFW switch toggle
  bool isLockedToggled = false; // New variable to track NSFW switch toggle

  @override
  void initState() {
    super.initState();
    name = 'test';
    email = "test@example.com";
    phoneNumber = "+919876543210";
    isTextFieldEnabled = false;
    checkNSFWEnabled();
    loadUsers();
    listSubscription();
  }

  void loadUsers() async {
    try {
      var promise = await account.get();
      var userEmail = promise.email;
      var userName = promise.name;

      setState(() {
        name = userName;
        email = userEmail;
        isLoading = false;
      });
      fetchAvatar();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateName() async {
    try {
      await account.updateName(name: name);

      if (kDebugMode) {
        print('name update to $name successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Authentication failed: $e');
      }
      showDialog(
        context: context,
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

  Future<void> fetchAvatar() async {
    var avatar = await avatars.getInitials(
      name: name,
      width: 120,
      height: 120,
    );

    setState(() {
      avatarImage = avatar;
    });
  }

  void _toggleTextFieldEnabled() {
    setState(() {
      isTextFieldEnabled = !isTextFieldEnabled;
    });
  }

  Future<void> _verifyEmail() async {
    // Email verification logic

    await account
        .createVerification(
      url: 'https://appwrite.io/',
    )
        .then((response) {
      if (kDebugMode) {
        print(response);
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Email Verification'),
          content: const Text('Verification link sent to your email.'),
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
    }).catchError((error) {
      if (kDebugMode) {
        print(error.response);
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Verification Link Not Sent'),
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
    });
  }

  Future<void> getSubscription() async {
    try {
      final promise = await account.get();
      final email = promise.email;
      final name = promise.name;
      await databases.createDocument(
        databaseId: '64c5fbb3ec64e7ac95a2',
        collectionId: '64c5fbbd4ea89a9c47a7',
        documentId: ID.unique(),
        data: {
          'userName': name,
          'userEmail': email,
          'isSubscribed': true,
        },
      ).then(
        (value) => setState(
          () {
            isSubscribed = true;
          },
        ),
      );

      setState(() {
        isSubscribed = true;
      });

      if (kDebugMode) {
        print('subscribed');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> listSubscription() async {
    try {
      final promise = await account.get();
      final email = promise.email;
      final name = promise.name;

      final data = await databases.listDocuments(
        databaseId: '64c5fbb3ec64e7ac95a2',
        collectionId: '64c5fbbd4ea89a9c47a7',
        queries: [
          Query.equal('userName', name),
          Query.equal('userEmail', email),
        ],
      );

      if (data.documents.isNotEmpty) {
        setState(() {
          isSubscribed = true;
        });
      } else {
        setState(() {
          isSubscribed = false;
        });
      }

      if (kDebugMode) {
        print('subscribed');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void checkNSFWEnabled() async {
    try {
      // Get the user preferences
      var prefs = await account.getPrefs();

      // Update the isNSFWEnabled state based on the user preferences
      setState(() {
        isNSFWEnabled = prefs.data['isNSFW'] ?? false;
        isLocked = prefs.data['isLocked'] ?? false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user preferences: $e');
      }
    }
  }

  Future<void> toggleNSFW() async {
    try {
      // Update the Appwrite document with the new NSFW status
      await account.updatePrefs(prefs: {
        'isNSFW': isNSFWEnabled,
      });

      if (kDebugMode) {
        print('isNSFW updated to $isNSFWEnabled successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please restart the app for the changes to take effect.'),
            duration: Duration(
                seconds: 5), // Optional: Set the duration of the SnackBar
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update isNSFW: $e');
      }
      // Show an error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Failed'),
          content: const Text('Failed to update isNSFW. Please try again.'),
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

  Future<void> toggleLock() async {
    try {
      // Update the Appwrite document with the new NSFW status
      await account.updatePrefs(prefs: {
        'isLocked': isLocked,
      });

      if (kDebugMode) {
        print('isLocked updated to $isLocked successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please restart the app for the changes to take effect.'),
            duration: Duration(
                seconds: 5), // Optional: Set the duration of the SnackBar
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update isNSFW: $e');
      }
      // Show an error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Failed'),
          content: const Text('Failed to update isNSFW. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    // print(isSubscribed);
    final result = avatars.getInitials();
    if (kDebugMode) {
      print(result);
    }

    Widget avatarWidget = CircleAvatar(
      radius: 60,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 58,
        backgroundImage: avatarImage != null ? MemoryImage(avatarImage!) : null,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? 'Loading...' : '$name\'s Profile',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: _toggleTextFieldEnabled,
            child: Icon(
              isTextFieldEnabled ? Icons.lock_open : Icons.edit,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 16.0),
                    Center(child: avatarWidget),
                    const SizedBox(height: 32.0),
                    Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              enabled: isTextFieldEnabled,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: name,
                                prefixIcon: const Icon(Icons.person),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isTextFieldEnabled
                                        ? Icons.lock_open
                                        : Icons.lock,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {},
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  updatename = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              enabled: isTextFieldEnabled,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: phoneNumber,
                                prefixIcon: const Icon(Icons.phone),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isTextFieldEnabled
                                        ? Icons.lock_open
                                        : Icons.lock,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {},
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  updatephoneNumber = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    enabled: isTextFieldEnabled,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: email,
                                      prefixIcon: const Icon(Icons.email),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isTextFieldEnabled
                                              ? Icons.lock_open
                                              : Icons.lock,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {},
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        updateemail = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                ElevatedButton(
                                  onPressed: _verifyEmail,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Verify',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        isSubscribed == true ? null : getSubscription();
                      },
                      child: Text(
                        isSubscribed == true ? 'Subscribed' : 'Subscribe',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // ListTile(
                    //   title: const Text(
                    //     'NSFW Content',
                    //     style: TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    //   trailing: Switch(
                    //     value: isNSFWEnabled,
                    //     onChanged: (newValue) {
                    //       setState(() {
                    //         isNSFWEnabled = newValue;
                    //       });

                    //       // Toggle the NSFW status
                    //       toggleNSFW();
                    //     },
                    //   ),
                    // ),
                    ListTile(
                      title: const Text(
                        'Set Screen lock',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Switch(
                        value: isLocked,
                        onChanged: (newValue) {
                          setState(() {
                            isLocked = newValue;
                          });

                          // Toggle the NSFW status
                          toggleLock();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomAppBar(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info,
                color: Colors.grey,
              ),
              SizedBox(width: 8.0),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
