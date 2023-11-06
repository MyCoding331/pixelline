import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'components/ad_screen_body.dart';

class AdScreen extends StatelessWidget {
  final NativeAd ad;

  const AdScreen({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdScreenBody(
        ad: ad,
      ),
    );
  }
}
