import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../service/ad_helper.dart';
import 'package:flutter/material.dart';

class BannerInlinePage extends StatefulWidget {
  const BannerInlinePage({Key? key}) : super(key: key);

  @override
  _BannerInlinePageState createState() => _BannerInlinePageState();
}

class _BannerInlinePageState extends State<BannerInlinePage> {
  late BannerAd _ad;
  bool _isAdLoaded = false;

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(
            child: AdWidget(ad: _ad),
            width: _ad.size.width.toDouble(),
            height: 72.0,
            alignment: Alignment.center,
          )
        : Container();
  }

  @override
  void initState() {
    super.initState();

    // Create a BannerAd instance
    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _ad.load();
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _ad.dispose();

    super.dispose();
  }
}
