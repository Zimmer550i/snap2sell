import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snap2sell/controllers/ebay_controller.dart';
import 'package:snap2sell/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Draft extends StatefulWidget {
  final Map<String, dynamic> json;
  const Draft({super.key, required this.json});

  @override
  State<Draft> createState() => _DraftState();
}

class _DraftState extends State<Draft> {
  final ebay = Get.find<EbayController>();
  List<TextEditingController?> controllers = [];

  List<String> titles = [];
  Map<String, String> titleKeys = {};
  Map<String, dynamic> json = {};

  @override
  void initState() {
    super.initState();
    ebay.checkPrevLogin();
    json = widget.json;
    getFields(json);
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  void getFields(Map<String, dynamic> data) {
    for (var i in data.entries) {
      var temp = i.key.split("_");
      var capitalized = temp.map((val) {
        if (val.isEmpty) return "";
        return val[0].toUpperCase() + val.substring(1);
      }).toList();

      String title = capitalized.join("-");
      title = splitCamelCase(title);
      titleKeys[title] = i.key;
      titles.add(title);

      if (i.value is Map) {
        controllers.add(null);
        getFields(i.value);
      } else if (i.value is String) {
        controllers.add(TextEditingController(text: i.value));
      } else {
        controllers.add(TextEditingController(text: i.value.toString()));
      }
    }
  }

  String splitCamelCase(String input) {
    final spaced = input.replaceAllMapped(
      RegExp(r'(?<=[a-z])([A-Z])'),
      (match) => ' ${match.group(1)}',
    );

    final words = spaced.split(' ').map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1);
    }).toList();

    return words.join(" ");
  }

  Map<String, dynamic> generateNewJson() {
    Map<String, dynamic> newJson = {};

    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i] == null) {
        continue;
      }
      if (titleKeys[titles[i]] == null) {
        debugPrint("<<<!>>> ${titles[i]} not found!");
      }

      final value = controllers[i]!.text.trim();

      newJson[titleKeys[titles[i]]!] = titleKeys[titles[i]]! == "categoryId"
          ? value
          : convertItems(value);
    }

    return newJson;
  }

  dynamic convertItems(String raw) {
    raw = raw.trim();

    if (int.tryParse(raw) != null) return int.parse(raw);
    if (double.tryParse(raw) != null) return double.parse(raw);
    if (raw == "true") return true;
    if (raw == "false") return false;

    if (raw.contains("[")) {
      String step1 = raw.replaceAllMapped(
        RegExp(r'(\w+):'),
        (match) => '"${match[1]}":',
      );
      String step2 = step1.replaceAllMapped(
        RegExp(r': ([^,\}\]]+)(,|\}|\])'), // Match everything until , } or ]
        (match) {
          String val = match[1]!.trim();
          // Leave booleans and numbers as-is
          if (val == "true" || val == "false") return ': $val${match[2]}';
          if (double.tryParse(val) != null) return ': $val${match[2]}';
          // Otherwise quote it
          return ': "${val.replaceAll('"', r'\"')}"${match[2]}';
        },
      );

      List<Map<String, dynamic>> listOfMaps = jsonDecode(
        step2,
      ).cast<Map<String, dynamic>>();

      return listOfMaps;
    }

    return raw;
  }

  Map<String, dynamic> updateNestedJson(
    Map<String, dynamic> original,
    Map<String, dynamic> updates,
  ) {
    original.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        original[key] = updateNestedJson(value, updates);
      } else if (value is List) {
        original[key] = value;
      }
    });

    updates.forEach((updateKey, updateValue) {
      if (original.containsKey(updateKey) && original[updateKey] is! Map) {
        original[updateKey] = updateValue;
      }
    });

    return original;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFCF8F5),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Draft Generated",
          style: TextStyle(
            fontSize: 26,
            color: Color(0xff003846),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 8,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      for (int i = 0; i < titles.length; i++)
                        Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titles[i],
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff003846),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (controllers[i] != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Color.fromARGB(255, 0, 113, 141),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controllers[i],
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: controllers[i]!.text,
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Icon(Icons.copy_rounded),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // connect(context);
                  launchEbayAuth();
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
                  json = updateNestedJson(json, generateNewJson());
                  ApiService().setToken(
                    "v^1.1#i^1#r^0#I^3#p^3#f^0#t^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",
                  );
                  // final message = "failed";
                  final message = await ebay.postToEbay(json);

                  if (message == "success") {
                    Get.snackbar(
                      "Success",
                      "Sell post has been posted successfully",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    setState(() {
                      ebay.images.clear();
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
                              "Post Draft",
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
    );
  }

  Future<void> launchEbayAuth() async {
    final Uri url = Uri.parse("${ApiService().baseUrl}/connect");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
