
import 'dart:io';

class EnvUtils {

  ///获取环境变量值
  static String? getEnvVal({required String key}) {
    return Platform.environment[key];
  }


}