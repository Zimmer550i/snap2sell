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
        print(">>>>>>>>>>> ${titles[i]}");
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
                  print("Updated Json: $json");
                  ApiService().setToken(
                    "v^1.1#i^1#f^0#I^3#p^3#r^0#t^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",
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
