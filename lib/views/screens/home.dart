import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap2sell/controllers/ebay_controller.dart';
import 'package:snap2sell/views/screens/camera_screen.dart';
import 'package:snap2sell/views/screens/draft.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final detailsCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final ebay = Get.find<EbayController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFCF8F5),
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
                  Obx(
                    () => GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        crossAxisCount: 3,
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        for (int i = 0; i < ebay.images.length; i++)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8,
                                  ),
                                  child: Image.file(
                                    ebay.images[i],
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
                                      ebay.images.removeAt(i);
                                    });
                                  },
                                  child: Container(
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
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
                              ebay.images.add(File(files[i].path));
                            }
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
                            Get.to(
                              () => CameraScreen(
                                onSubmit: (capturedPhotos) {
                                  setState(() {
                                    ebay.images.addAll(capturedPhotos);
                                  });
                                },
                              ),
                            );
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
                      final message = await ebay.generateDraft(
                        detailsCtrl.text.isEmpty
                            ? "Sell this"
                            : detailsCtrl.text.trim(),
                      );

                      if (message.contains("success")) {
                        Get.to(
                          () => Draft(
                            json: jsonDecode(
                              message.replaceAll("success ", ""),
                            ),
                          ),
                        );
                        Get.snackbar(
                          "Success",
                          "Draft generated successfully",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
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
}
