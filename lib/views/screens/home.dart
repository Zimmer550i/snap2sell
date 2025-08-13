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
  List<File?> images = [];
  final _focusNode = FocusNode();
  final ebay = Get.find<EbayController>();

  @override
  void initState() {
    super.initState();
    ebay.checkPrevLogin();
  }

  @override
  Widget build(BuildContext context) {
    // ApiService().setToken("bla bla bla", key: "access_token");
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                  child: images[i] != null
                                      ? Image.file(
                                          images[i]!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Color(0xffeff3f4),
                                          ),
                                          child: FittedBox(
                                            child: Text(
                                              "Image ${i + 1}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff003846),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
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
                  Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xff003846),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Generate Draft Listing",
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
        ApiService().setToken(data['access_token'], key: "access_token");
      }
      if (data["refresh_token"] != null) {
        ApiService().setToken(data['refresh_token'], key: "refresh_token");
      }
    }
    ebay.checkPrevLogin();
  }
}
