import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snap2sell/controllers/ebay_controller.dart';
import 'package:snap2sell/services/api_service.dart';
import 'package:snap2sell/views/screens/webview_screen.dart';

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
      newJson[titleKeys[titles[i]]!] = controllers[i]!.text.trim();
    }

    return newJson;
  }

  Map<String, dynamic> updateNestedJson(
    Map<String, dynamic> original,
    Map<String, dynamic> updates,
  ) {
    original.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        original[key] = updateNestedJson(value, updates);
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
                  json = updateNestedJson(json, generateNewJson());
                  // ApiService().setToken(
                  //   "v^1.1#i^1#r^0#p^3#I^3#f^0#t^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",
                  // );
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
