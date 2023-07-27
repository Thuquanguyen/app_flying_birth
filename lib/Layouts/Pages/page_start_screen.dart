// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables
import 'package:flappy_bird/Layouts/Widgets/widget_bird.dart';
import 'package:flappy_bird/Resources/strings.dart';
import 'package:flappy_bird/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import '../../Global/constant.dart';
import '../../Global/functions.dart';
import '../../ads/app_lifecircle_factory.dart';
import '../../ads/open_app_ads_manage.dart';
import '../Widgets/widget_gradient _button.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final myBox = Hive.box('user');
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    // Todo : initialize the database  <---
    init();
    initAds();
    _loadInterstitialAd();
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    AppLifecycleReactor(appOpenAdManager: appOpenAdManager)
        .listenToAppStateChanges();
    super.initState();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              navigate(context, Str.settings);
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  initAds() {
    BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: background(Str.image),
        child: Stack(
          children: [
            if (_bannerAd != null)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: kToolbarHeight),
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            Column(
              children: [
                // Flappy bird text
                Container(
                    margin: EdgeInsets.only(top: size.height * 0.25),
                    child: myText("FlappyBird", Colors.white, 70)),
                Bird(yAxis, birdWidth, birdHeight),
                _buttons(context),
                AboutUs(
                  size: size,
                  interstitialAd: _interstitialAd,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Column _buttons(BuildContext context) {
    return Column(
      children: [
        Button(
          buttonType: "",
          height: 60,
          width: 278,
          icon: Icon(
            Icons.play_arrow_rounded,
            size: 60,
            color: Colors.green,
          ),
          page: Str.gamePage,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Button(
              buttonType: "icon",
              height: 60,
              width: 110,
              icon: Icon(
                Icons.settings,
                size: 40,
                color: Colors.grey.shade900,
              ),
              callBack: () {
                if (_interstitialAd != null) {
                  _interstitialAd?.show();
                } else {
                  navigate(context, Str.settings);
                }
              },
              page: Str.settings,
            ),
            Button(
              buttonType: "icon",
              height: 60,
              width: 110,
              icon: Icon(
                Icons.star,
                size: 40,
                color: Colors.deepOrange,
              ),
              page: Str.rateUs,
            ),
          ],
        ),
      ],
    );
  }
}

// three buttons


class AboutUs extends StatelessWidget {
  final Size size;
  final InterstitialAd? interstitialAd;

  AboutUs({required this.size,required this.interstitialAd, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: size.height * 0.2),
      child: GestureDetector(
          onTap: () {
            if(interstitialAd == null){
              showDialog(
                context: context,
                builder: (context) {
                  return dialog(context);
                },
              );
            }else{
              interstitialAd?.show();
              showDialog(
                context: context,
                builder: (context) {
                  return dialog(context);
                },
              );
            }
          },
          child: myText("About Us", Colors.white, 20)),
    );
  }
}
