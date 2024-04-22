import 'package:get/get.dart';
import 'package:server_entry_dashboard/utils/translations/en_us.dart';
import 'package:server_entry_dashboard/utils/translations/zh_cn.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': zh_cn,
        'en_US': en_us,
      };
}
