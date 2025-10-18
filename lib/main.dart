import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snap2sell/controllers/ebay_controller.dart';
import 'package:snap2sell/services/api_service.dart';
import 'package:snap2sell/views/screens/splash.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Get.put(EbayController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle app launch via deep link
    final uri = await _appLinks.getInitialLink();
    if (uri != null) _handleLink(uri);

    // Handle incoming links while app is running
    _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  void _handleLink(Uri uri) async {
    if (uri.host == 'callback') {
      final rawData = uri.fragment;
      final decodedJson = utf8.decode(base64.decode(rawData));

      final Map<String, dynamic> data = json.decode(decodedJson);

      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      if (accessToken != null) {
        ApiService().setToken(accessToken);
      }
      if (refreshToken != null) {
        ApiService().setToken(refreshToken, key: "refresh_token");
      }

      if (await Get.find<EbayController>().checkPrevLogin()) {
        Get.snackbar(
          "Success",
          "Ebay account successfully connected",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(home: Splash());
  }
}
