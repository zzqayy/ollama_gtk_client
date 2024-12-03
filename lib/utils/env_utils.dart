
import 'dart:io';

class EnvUtils {

  ///获取环境变量值
  static String? getEnvVal({required String key}) {
    return Platform.environment[key];
  }

  ///获取家目录
  static String? getHomeEnv() {
    if(Platform.isWindows) {
      return getEnvVal(key: "USERPROFILE");
    }else if(Platform.isLinux) {
      return getEnvVal(key: "HOME");
    }else {
      return null;
    }
  }
  
}