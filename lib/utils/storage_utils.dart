import 'dart:io';

import '/utils/env_utils.dart';

class StorageUtils {

  ///文件数据目录名
  static const String appDirName = "ollama_gtk_client";

  ///数据文件夹
  static Future<Directory> getAppDateDir() async {
    String? homeDirStr = EnvUtils.getEnvVal(key: "HOME");
    if(homeDirStr == null) {
      throw Exception("获取家目录失败");
    }
    return Directory("$homeDirStr/.local/share/$appDirName");
  }

  ///获取缓存目录
  static Future<Directory> getTmpDir() async {
    String? homeDirStr = EnvUtils.getEnvVal(key: "HOME");
    Directory appDir = Directory("$homeDirStr/.cache/$appDirName");
    if(!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }
    return appDir;
  }

  ///获取数据目录
  static Future<Directory> getAppConfigDir() async {
    String? homeDirStr = EnvUtils.getEnvVal(key: "HOME");
    Directory appDir = Directory("$homeDirStr/.config/$appDirName");
    if(!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }
    return appDir;
  }

  ///获取下载的临时目录
  static Future<Directory> getTmpDownloadsDir() async {
    String? homeDirStr = EnvUtils.getEnvVal(key: "HOME");
    Directory appDir = Directory("$homeDirStr/.cache/$appDirName/Downloads");
    if(!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }
    return appDir;
  }

  ///获取截图的临时目录
  static Future<Directory> getTmpPictureDir() async {
    String? homeDirStr = EnvUtils.getEnvVal(key: "HOME");
    Directory captureDir = Directory("$homeDirStr/.cache/$appDirName/Pictures/capture");
    if(!captureDir.existsSync()) {
      captureDir.createSync(recursive: true);
    }
    return captureDir;
  }

}
