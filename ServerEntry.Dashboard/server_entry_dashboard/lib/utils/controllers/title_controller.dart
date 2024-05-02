import 'package:get/get.dart';

class TitleController extends GetxController {
  final titlePrefix = 'Server Entry', titleSeparator = '|';

  var title = 'Server Entry'.obs;

  void updateTitle(String content) {
    title.value = '$titlePrefix $titleSeparator $content';
  }
}
