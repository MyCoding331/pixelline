// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelline/model/appwrite_sevices.dart';
import 'appwrite_auth_login_screen.dart';

class Auth extends StatefulWidget {
  const Auth({
    Key? key,
  }) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _password;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        await account.create(
          email: _email!,
          password: _password!,
          userId: uniqueId,
          name: _name!,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );

        if (kDebugMode) {
          print('Authentication successful');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Authentication failed: $e');
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hold on'),
              content: const Text('Do you want to leave this app?'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallpaper Auth'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Sign Up',
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
                            labelText: 'Name',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (input) => input!.trim().isEmpty
                              ? 'Please enter a valid name'
                              : null,
                          onSaved: (input) => _name = input!,
                        ),
                      ),
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
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                          validator: (input) => input!.length < 6
                              ? 'Must be at least 6 characters'
                              : null,
                          onSaved: (input) => _password = input!,
                          obscureText: !_isPasswordVisible,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12000),
                            color: Colors.black,
                          ),
                          width: 120,
                          height: 40,
                          child: _isLoading
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
                                      _signUp();
                                    }
                                  },
                                  child: ElevatedButton(
                                    onPressed: _signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .blue, // Button background color
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
                                      'Sign Up',
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
                            const Text("Already an member?"),
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              ),
                              child: const Text(
                                'Login',
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
      ),
    );
  }
}
