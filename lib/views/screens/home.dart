import 'dart:io';

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<File?> images = List.generate(6, (i) => null);
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      for (int i = 0; i < 6; i++)
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(8),
                          child: images[i] != null
                              ? Image.file(images[i]!, fit: BoxFit.cover)
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
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        style: TextStyle(fontSize: 26, color: Color(0xff003846)),
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
                  Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffdde7e7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Connect your eBay",
                        style: TextStyle(
                          fontSize: 26,
                          color: Color(0xff003846),
                          fontWeight: FontWeight.w500,
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
}
