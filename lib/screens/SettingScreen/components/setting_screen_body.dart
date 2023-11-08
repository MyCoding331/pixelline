// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixelline/screens/AuthScreen/auth_screen.dart';
import 'package:pixelline/screens/SettingScreen/components/opt_component.dart';
import 'package:pixelline/services/Appwrite/appwrite_sevices.dart';
import 'package:pixelline/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingScreenBody extends StatefulWidget {
  const SettingScreenBody({super.key});

  @override
  State<SettingScreenBody> createState() => _SettingScreenBodyState();
}

class _SettingScreenBodyState extends State<SettingScreenBody> {
  late String name;

  String updatename = '';

  late String email;

  String updateemail = '';

  late String phoneNumber;

  String updatephoneNumber = '';
  String country = '';

  bool isLoading = true;

  bool isSubscribed = false;

  late bool isTextFieldEnabled;

  Uint8List? avatarImage;

  bool isNSFWEnabled = false;

  bool isLocked = false;

  bool similarOnSwipe = false;

  bool isNSFWToggled = false;

  bool isLockedToggled = false;
  bool emailVarificationStatus = false;
  bool phoneVarificationStatus = false;
  bool otpSend = false;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? pref = prefs.getBool('similarOnSwipe') ?? false;
    setState(() {
      similarOnSwipe = pref;
      country = prefs.getString('country') ?? 'N/A';
    });
    try {
      var promise = await account.get();
      var userEmail = promise.email;
      var userName = promise.name;
      var userPhone = promise.phone;

      setState(() {
        name = userName;
        email = userEmail;
        phoneNumber = userPhone.isEmpty ? "+919876543210" : userPhone;
        isLoading = false;
        emailVarificationStatus = promise.emailVerification;
        phoneVarificationStatus = promise.phoneVerification;
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

  Future<void> _updateUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final password = prefs.getString('userPassword');
      await account.updateName(name: updatename);
      await account.updatePhone(
          phone: '+91$updatephoneNumber', password: password!);

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final image = prefs.getString('avatarImage') ?? '';
    dynamic avatar = image.isEmpty
        ? await avatars.getInitials(
            name: name,
            width: 120,
            height: 120,
          )
        : avatars.getImage(url: image);

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
    const String url =
        'https://pixellie-backend-api.vercel.app/emailVerification';
    if (kDebugMode) {
      print(url);
    }
    await account
        .createVerification(
      url: url,
    )
        .then((response) {
      if (kDebugMode) {
        print(response.secret);
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
      await database.createDocument(
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

      final data = await database.listDocuments(
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

  Future<void> checkNSFWEnabled() async {
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

  Future<void> toggleSimilar() async {
    try {
      // Update the Appwrite document with the new NSFW status
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Update the Appwrite document with the new NSFW status
      await prefs.setBool(
        'similarOnSwipe',
        similarOnSwipe,
      );

      if (kDebugMode) {
        print('similarOnSwipe updated to $similarOnSwipe successfully');
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

  void setOtpSend(bool value) {
    setState(() {
      otpSend = value;
    });
  }

  Future<void> deleteUser() async {
    final res = await account.get();
    final String userId = res.$id;
    if (kDebugMode) {
      print(userId);
    }
    final response = await http.delete(
      Uri.parse(
          'https://pixellie-backend-api.vercel.app/deleteUser?userId=$userId'),
    );

    if (response.statusCode == 200) {
      // User deletion was successful.
      if (kDebugMode) {
        print('User has been deleted.');
      }
      if (kDebugMode) {
        print(response.body);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const AuthScreen(),
        ),
      );
    } else {
      // User deletion failed. Handle the error.
      if (kDebugMode) {
        print('User deletion failed with status code: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(isSubscribed);
    final result = avatars.getInitials();
    if (kDebugMode) {
      print(result);
    }

    return Scaffold(
      appBar: appbar(),
      body: isLoading ? CircularIndicator() : settingsCard(context),
      bottomNavigationBar: bottomAppBar(),
    );
  }

  Stack settingsCard(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 16.0),
                AvatarComp(avatarImage: avatarImage, fetchAvatar: fetchAvatar),
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
                        nameTextField(),
                        const SizedBox(height: 16.0),
                        phoneNoTextField(),
                        const SizedBox(height: 16.0),
                        emailTextField(),
                        const SizedBox(height: 16.0),
                        countryTextField(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                saveChangesButton(),
                const SizedBox(height: 16.0),
                deleteAccoundButton(context),
                const SizedBox(height: 16.0),
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
                ListTile(
                  title: const Text(
                    'Show similar on swipe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Switch(
                    value: similarOnSwipe,
                    onChanged: (newValue) {
                      setState(() {
                        similarOnSwipe = newValue;
                      });

                      toggleSimilar();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (otpSend == true)
          Center(
            child: OtpComponent(
              onOtpCompleted: () {
                setOtpSend(false); // Set otpSent to false in the parent widget
              },
              loadUsers: loadUsers,
            ),
          )
      ],
    );
  }

  BottomAppBar bottomAppBar() {
    return const BottomAppBar(
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
              'Version 1.0.2',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
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
    );
  }

  ElevatedButton deleteAccoundButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.amber,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Wait...!!!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you absolutely sure you want to delete your account?',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        deleteUser().then(
                          (_) => Navigator.pop(context),
                        );
                      },
                      icon: const Icon(Icons.delete, size: 20),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      child: const Text(
        'Delete Account',
        style: TextStyle(
          color: Colors.red,
          fontSize: 16,
        ),
      ),
    );
  }

  ElevatedButton saveChangesButton() {
    return ElevatedButton(
      onPressed: () {
        _updateUserDetails();
      },
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
    );
  }

  TextField countryTextField() {
    return TextField(
      enabled: false,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: country,
        prefixIcon: const Icon(Icons.flag_outlined),
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
    );
  }

  Row emailTextField() {
    return Row(
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
                  isTextFieldEnabled ? Icons.lock_open : Icons.lock,
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
                updateemail = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8.0),
        if (emailVarificationStatus == false)
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
          )
        else
          const SizedBox.shrink()
      ],
    );
  }

  Row phoneNoTextField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            enabled: isTextFieldEnabled,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: phoneNumber,
              prefixIcon: const Icon(Icons.phone),
              suffixIcon: IconButton(
                icon: Icon(
                  isTextFieldEnabled ? Icons.lock_open : Icons.lock,
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
        ),
        const SizedBox(width: 8.0),
        if (phoneVarificationStatus == false)
          ElevatedButton(
            onPressed: () {
              account.createPhoneVerification().then(
                    (_) => setState(() {
                      otpSend = true;
                    }),
                  );
            },
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
          )
        else
          const SizedBox.shrink()
      ],
    );
  }

  Row nameTextField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            enabled: isTextFieldEnabled,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              labelText: name,
              prefixIcon: const Icon(Icons.person),
              suffixIcon: IconButton(
                icon: Icon(
                  isTextFieldEnabled ? Icons.lock_open : Icons.lock,
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
        ),
        const SizedBox(width: 8.0),
      ],
    );
  }
}

class AvatarComp extends StatefulWidget {
  final Uint8List? avatarImage;
  final fetchAvatar;
  const AvatarComp({super.key, required this.avatarImage, this.fetchAvatar});

  @override
  State<AvatarComp> createState() => _AvatarCompState();
}

class _AvatarCompState extends State<AvatarComp> {
  String appwriteBucketId = '6544d3ba2b558ae312fd';

  String profileImage = '';
  final picker = ImagePicker();

  Future<void> getProfileImage({required String type}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pickedFile;
    if (type == 'camera') {
      pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          maxHeight: 480,
          maxWidth: 640,
          imageQuality: 50);
    } else if (type == 'gallery') {
      pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 480,
        maxWidth: 640,
        imageQuality: 50,
      );
    } else {
      pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );
    }

    if (pickedFile != null) {
      String imageName = pickedFile.path;
      if (kDebugMode) {
        print('imageName is $imageName');
      }

      final response = await storage.createFile(
        file: InputFile.fromPath(path: imageName),
        bucketId: appwriteBucketId,
        fileId: uniqueId,
      );

      String fileId = response.$id;
      final localFileId = await prefs.setString('local', fileId);

      await storage.getFileDownload(
        fileId: fileId,
        bucketId: appwriteBucketId,
      );

      setState(() {
        profileImage =
            'https://cloud.appwrite.io/v1/storage/buckets/$appwriteBucketId/files/$localFileId/view?project=6544d39c4a5fbfb5bfd2&mode=admin';
      });
      await prefs.setString('avatarImage',
          'https://cloud.appwrite.io/v1/storage/buckets/$appwriteBucketId/files/$localFileId/view?project=6544d39c4a5fbfb5bfd2&mode=admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget = Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 58,
            backgroundImage: widget.avatarImage != null
                ? MemoryImage(widget.avatarImage!)
                : null,
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              getProfileImage(type: 'gallery').then(
                (value) => widget.fetchAvatar(),
              );
            },
            child: Container(
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2000),
                color: Colors.white,
              ),
              child: const Icon(Icons.edit_outlined, size: 23),
            ),
          ),
        )
      ],
    );
    return Center(child: avatarWidget);
  }
}
