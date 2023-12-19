// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelline/util/functions.dart';
import 'package:pixelline/util/util.dart';

class AuthScreenBody extends StatefulWidget {
  const AuthScreenBody({super.key});

  @override
  State<AuthScreenBody> createState() => _AuthScreenBodyState();
}

class _AuthScreenBodyState extends State<AuthScreenBody> {
  int _selectedIndex = 0;

  String loginemail = '';

  String email = '';

  String password = '';

  String loginpassword = '';

  String name = '';

  late String randomString;

  bool isLogin = false;

  bool isSignUp = false;

  bool _isPasswordVisible = false;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    randomString = randomStringGenerataor(20);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signUp() async {
    setState(() {
      isSignUp = true;
    });
    try {
      await userSignUp(email: email, password: password, name: name);
      setState(() {
        _selectedIndex = 0;
        isSignUp = false;
      });
      showSnackBar(context, 'Registration successful! Now login.');
    } catch (error) {
      if (kDebugMode) {
        print('Error during sign up: $error');
      }
      showSnackBar(context, 'check the credentials before signUp');
      setState(() {
        isSignUp = false;
      });
      // Handle any errors that occurred during sign up
    }
  }

  Future<void> _login() async {
    setState(() {
      isLogin = true;
    });
    try {
      await userLogin(email: email, password: password);
      setState(() {
        isLogin = false;
      });
    } catch (error) {
      showSnackBar(context, 'Opps...!! check the username & password');
      // Handle any errors that occurred during sign in
    }
    setState(() {
      isLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56.0),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100.0,
                  width: 100.0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _onItemTapped(0);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedIndex == 0
                                ? Colors.white
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 6),
                          width: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.login,
                                color: _selectedIndex == 0
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  color: _selectedIndex == 0
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _onItemTapped(1);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedIndex == 1
                                ? Colors.white
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 6),
                          width: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.person_add,
                                color: _selectedIndex == 1
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: _selectedIndex == 1
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            _selectedIndex == 0
                                ? Icons.login
                                : Icons.person_add,
                            color: Colors.blue,
                            size: 28.0,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            _selectedIndex == 0
                                ? 'Welcome Back'
                                : 'Create an Account',
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedIndex == 1) const SizedBox(height: 16.0),
                    if (_selectedIndex == 1)
                      TextField(
                        onChanged: (value) => {
                          setState(() {
                            name = value;
                          })
                        },
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        fillColor: Colors.grey[200],
                      ),
                      onChanged: (value) => {
                        setState(() {
                          email = value;
                        })
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        fillColor: Colors.grey[200],
                      ),
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _selectedIndex == 0 ? _login() : _signUp();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: (isLogin || isSignUp)
                            ? SizedBox(
                                // margin: EdgeInsets.all(12),
                                height: 22, width: 22,
                                child: CircularIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _selectedIndex == 0 ? 'Sign In' : 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const Center(
                      child: Text(
                        '---------- Or Continue With ----------',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            iconSize: 40,
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/images/google.png',
                              height: 60.0,
                              width: 60.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                          IconButton(
                            iconSize: 40,
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/images/apple.png',
                              height: 60.0,
                              width: 60.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                          IconButton(
                            iconSize: 40,
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/images/facebook.png',
                              height: 60.0,
                              width: 60.0,
                              fit: BoxFit.fill,
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
