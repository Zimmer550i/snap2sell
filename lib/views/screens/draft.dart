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
                  ApiService().setToken(
                    "v^1.1#i^1#I^3#p^3#r^0#f^0#t^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",
                  );
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
