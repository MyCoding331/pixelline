// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pixelline/util/functions.dart';
import 'package:pixelline/util/util.dart';
import 'package:pixelline/wallpaper_screen.dart';

class LocalAuthScreenBody extends StatefulWidget {
  const LocalAuthScreenBody({super.key});

  @override
  State<LocalAuthScreenBody> createState() => _LocalAuthScreenBodyState();
}

class _LocalAuthScreenBodyState extends State<LocalAuthScreenBody> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  bool isAuth = false;

  @override
  void initState() {
    super.initState();
    _authenticate(context);
  }

  Future<void> _authenticate(BuildContext context) async {
    bool authenticated = false;
    try {
      authenticated =
          await localAuthFunction(authenticated, _localAuthentication);
      setState(() {
        if (authenticated) {
          isAuth = true;
        }
      });
    } catch (e) {
      // Handle errors here
      if (kDebugMode) {
        print('Authentication error: $e');
      }
    }

    if (authenticated) {
      // Navigate to the authenticated content
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const WallpaperScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to our Awesome App!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            const Icon(
              Icons.fingerprint,
              size: 80,
              color: Colors.black,
            ),
            const SizedBox(height: 20),
            if (isAuth)
              CircularIndicator()
            else
              ElevatedButton.icon(
                onPressed: () => _authenticate(context),
                icon: const Icon(Icons.fingerprint),
                label: const Text('Authenticate'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
