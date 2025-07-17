import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snap2sell/views/screens/home.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(seconds: 2), () => Get.off(() => Home()));
    });
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Hero(
              tag: "logo",
              child: Image.asset("assets/images/logo_with_name.png"),
            ),
          ],
        ),
      ),
    );
  }
}
