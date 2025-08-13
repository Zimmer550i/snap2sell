import 'package:get/get.dart';
import 'package:snap2sell/services/shared_prefs_service.dart';

class EbayController extends GetxController {
  RxBool isConnected = RxBool(false);

  void checkPrevLogin() async {
    final String? accessToken = await SharedPrefsService.get("access_token");
    final String? refreshToken = await SharedPrefsService.get("refresh_token");

    if (accessToken != null && refreshToken != null) {
      isConnected(true);
    }
  }
}
