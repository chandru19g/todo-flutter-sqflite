import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/note_list.dart';

AppOpenAd? openAd;

Future<void> loadAd() async {
  await AppOpenAd.load(
    adUnitId: 'ca-app-pub-3940256099942544/3419835294',
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        print('Ad Loaded');
        openAd = ad;
        openAd!.show();
      },
      onAdFailedToLoad: (error) {
        print('Ad Failed to Load $error');
      },
    ),
    orientation: AppOpenAd.orientationPortrait,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  await loadAd();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const NoteList(),
    );
  }
}
