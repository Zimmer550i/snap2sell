import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:snap2sell/services/api_service.dart';
import 'package:snap2sell/services/shared_prefs_service.dart';

class EbayController extends GetxController {
  final api = ApiService();

  RxBool isConnected = RxBool(false);
  RxBool isLoading = RxBool(false);

  Future<bool> checkPrevLogin() async {
    final String? accessToken = await SharedPrefsService.get("token");
    final String? refreshToken = await SharedPrefsService.get("refresh_token");

    if (accessToken != null && refreshToken != null) {
      isConnected(true);
      return true;
    } else {
      return false;
    }
  }

  Future<String> postToEbay(List<File> images, String? description) async {
    try {
      isLoading(true);
      final response = await api.post(
        "/post",
        {"images": images, "description": description},
        isMultiPart: true,
        authReq: true,
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "success";
      } else if (response.statusCode == 401) {
        final message = await refreshAuthToken();
        if (message == "success") {
          return postToEbay(images, description);
        } else {
          return "Please connect your Ebay account first";
        }
      } else {
        return body["error"]["errors"][0]['longMessage'] ?? body["error"]["errors"][0]['message'] ?? "Something went wrong";
      }
    } catch (e) {
      return e.toString();
    } finally {
      isLoading(false);
    }
  }

  Future<String> refreshAuthToken() async {
    final token = await SharedPrefsService.get('refresh_token');
    if (token == null) {
      return "failed";
    }
    final response = await http.get(
      Uri.parse("${api.baseUrl}/refresh-token"),
      headers: {'Authorization': 'Bearer $token'},
    );

    final accessToken = jsonDecode(response.body)['access_token'];

    api.setToken(accessToken);

    return "success";
  }
}
