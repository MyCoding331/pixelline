// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:pixelline/services/Appwrite/appwrite_sevices.dart';
import 'package:pixelline/util/util.dart';

class OtpComponent extends StatefulWidget {
  final VoidCallback onOtpCompleted;
  final VoidCallback loadUsers;
  const OtpComponent({
    super.key,
    required this.onOtpCompleted,
    required this.loadUsers,
  });

  @override
  State<OtpComponent> createState() => _OtpComponentState();
}

class _OtpComponentState extends State<OtpComponent> {
  String otp = '';
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  final focusedBorderColor = const Color.fromRGBO(23, 171, 144, 1);
  final borderColor = const Color.fromRGBO(23, 171, 144, 0.4);

  verifyOtp() async {
    var res = await account.get();
    final userId = res.$id;
    try {
      await account.updatePhoneVerification(userId: userId, secret: otp).then(
            (_) => {
              widget.onOtpCompleted(),
              widget.loadUsers(),
            },
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
        showSnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width / 1.2,
      height: height / 2.2,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            closeButton(),
            pinComponent(),
          ],
        ),
      ),
    );
  }

  Positioned closeButton() {
    return Positioned(
      right: 8,
      top: 8,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.black),
        onPressed: () {
          widget.onOtpCompleted();
        },
      ),
    );
  }

  Padding pinComponent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Icon(
              Icons.lock_open,
              size: 64,
              color: Colors.black,
            ),
          ),
          const Text(
            'Enter your 6-digit PIN',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          pinContainer(),
          const SizedBox(height: 16),
          verifyPinButton(),
        ],
      ),
    );
  }

  ElevatedButton verifyPinButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onPressed: () {
        verifyOtp();
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Text(
          'Verify',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Pinput pinContainer() {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        color: Colors.white,
      ),
    );
    return Pinput(
      length: 6,
      controller: pinController,
      focusNode: focusNode,
      androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
      listenForMultipleSmsOnAndroid: true,
      defaultPinTheme: defaultPinTheme,
      separatorBuilder: (index) => const SizedBox(width: 8),
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      onCompleted: (pin) {
        setState(() {
          otp = pin;
        });
      },
      onChanged: (value) {
        setState(() {
          otp = value;
        });
      },
      cursor: const SizedBox.shrink(),
      errorPinTheme: defaultPinTheme.copyWith(
        textStyle: const TextStyle(
          color: Colors.redAccent,
        ),
        decoration: defaultPinTheme.decoration!.copyWith(
          border: Border.all(color: Colors.redAccent),
        ),
      ),
      errorText: 'Incorrect PIN. Please try again.',
    );
  }
}
