import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap2sell/controllers/ebay_controller.dart';
import 'package:snap2sell/services/api_service.dart';
import 'package:snap2sell/views/screens/webview_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<File> images = [];

  final detailsCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final ebay = Get.find<EbayController>();

  @override
  void initState() {
    super.initState();
    ebay.checkPrevLogin();
  }

  @override
  Widget build(BuildContext context) {
    ApiService().setToken(
      "v^1.1#i^1#I^3#f^0#p^3#r^0#t^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",
    );
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: "logo",
                    child: Image.asset("assets/images/logo_with_name.png"),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Upload up to 6 photos",
                    style: TextStyle(
                      fontSize: 26,
                      color: Color(0xff003846),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      crossAxisCount: 3,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      for (int i = 0; i < images.length; i++)
                        GestureDetector(
                          onTap: () async {
                            XFile? temp = await ImagePicker().pickImage(
                              source: ImageSource.camera,
                            );

                            if (temp != null) {
                              setState(() {
                                images[i] = File(temp.path);
                              });
                            }
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8,
                                  ),
                                  child: Image.file(
                                    images[i],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -5,
                                right: -5,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      images.removeAt(i);
                                    });
                                  },
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            List<XFile> files = await ImagePicker()
                                .pickMultiImage();

                            for (int i = 0; i < files.length; i++) {
                              images.add(File(files[i].path));
                            }
                            setState(() {});
                          },
                          child: Container(
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xffdde7e7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.add_to_photos_rounded, size: 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            for (int i = 0; i < 4; i++) {
                              var temp = await ImagePicker().pickImage(
                                source: ImageSource.camera,
                              );
                              if (temp != null) {
                                images.add(File(temp.path));
                              } else {
                                break;
                              }
                            }
                            setState(() {});
                          },
                          child: Container(
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xffdde7e7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.camera_alt_rounded, size: 36),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Additional details",
                        style: TextStyle(
                          fontSize: 26,
                          color: Color(0xff003846),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(optional)",
                        style: TextStyle(
                          fontSize: 26,
                          color: Color(0xff003846),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xff7e99a0)),
                    ),
                    child: TextField(
                      controller: detailsCtrl,
                      focusNode: _focusNode,
                      onTapOutside: (_) {
                        _focusNode.unfocus();
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            "For price, condition and other info that cannot be realistically established from snaps.",
                        hintStyle: TextStyle(
                          color: Color(0xff537a85),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      connect(context);
                    },
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xffdde7e7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Obx(
                          () => Text(
                            "Connect your eBay${ebay.isConnected.value ? "✅" : "❌"}",
                            style: TextStyle(
                              fontSize: 26,
                              color: Color(0xff003846),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final message = await ebay.postToEbay(
                        images,
                        detailsCtrl.text.trim(),
                      );

                      if (message == "success") {
                        Get.snackbar(
                          "Success",
                          "Sell post has been posted successfully",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        setState(() {
                          images.clear();
                          detailsCtrl.clear();
                        });
                      } else {
                        Get.snackbar(
                          "Failed",
                          message,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xff003846),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(
                        () => Center(
                          child: ebay.isLoading.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Generate Draft Listing",
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void connect(BuildContext context) async {
    final body = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WebViewScreen(startUrl: "${ApiService().baseUrl}/connect"),
      ),
    );

    if (body != null) {
      final data = jsonDecode(body);

      if (data["access_token"] != null) {
        ApiService().setToken(data['access_token']);
      }
      if (data["refresh_token"] != null) {
        ApiService().setToken(data['refresh_token'], key: "refresh_token");
      }
    }
    if (await ebay.checkPrevLogin()) {
      Get.snackbar(
        "Success",
        "Ebay account successfully connected",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}
