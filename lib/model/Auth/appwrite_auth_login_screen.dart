// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelline/model/appwrite_sevices.dart';
import 'package:pixelline/wallpaper_screen.dart';

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  bool _isLoadingLogin = false;
  bool isLoginPasswordVisible = false;
  void _togglePasswordVisibility() {
    setState(() {
      isLoginPasswordVisible = !isLoginPasswordVisible;
    });
  }

  @override
  void initState() {
    super.initState();

    checkUserSession();
  }

  Future<bool> checkUserSession() async {
    try {
      // Check if the user session exists
      await account.get();
      return true;
    } catch (e) {
      // Handle any errors that occurred while checking the user session
      // if (kDebugMode) {
      if (kDebugMode) {
        print('Error: $e');
      }
      // }
      return false;
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoadingLogin = true;
      });

      try {
        await account
            .createEmailSession(
              email: _email!,
              password: _password!,
            )
            .then(
              (_) => checkUserSession(),
            );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WallpaperScreen(),
          ),
        );

        if (kDebugMode) {
          print('Authentication successful');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Authentication failed: $e');
        }
        // Handle the authentication failure here
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Authentication Failed'),
            content: const Text('check your email and password.'),
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

      setState(() {
        _isLoadingLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper Auth'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Login In',
                style: TextStyle(
                  fontFamily: 'Billabong',
                  fontSize: 50.0,
                ),
              ),
              const SizedBox(height: 40.0),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (input) {
                          if (input!.isEmpty) {
                            return 'Please enter an email';
                          } else if (!input.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (input) => _email = input!,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: const Icon(Icons.lock_person_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(isLoginPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        validator: (input) => input!.length < 6
                            ? 'Must be at least 6 characters'
                            : null,
                        onSaved: (input) => _password = input!,
                        obscureText: !isLoginPasswordVisible,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 40,
                        right: 40,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12000),
                          color: Colors.black,
                        ),
                        width: 120,
                        height: 40,
                        child: _isLoadingLogin
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.0),
                                ),
                              )
                            : RawKeyboardListener(
                                focusNode:
                                    FocusNode(), // Create a new FocusNode to receive keyboard events
                                onKey: (RawKeyEvent event) {
                                  if (event.runtimeType == RawKeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.enter) {
                                    // Trigger the login action when the Enter key is pressed
                                    _login();
                                  }
                                },

                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.black, // Button background color
                                    foregroundColor:
                                        Colors.white, // Button text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10000.0), // Button border radius
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 7.0,
                                        horizontal: 24.0), // Button padding
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      // color: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        children: [
                          const Text("Are you new?"),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.black,
                                // fontSize: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
