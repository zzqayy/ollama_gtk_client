import 'dart:io';

import 'package:ollama_gtk_client/utils/storage_utils.dart';

class ProcessUtils {

  //kde区域截图
  static Future<String> captureKDEArea() async {
    var tmpPictureDir = await StorageUtils.getTmpPictureDir();
    var now = DateTime.now();
    String pictureImagePath = "${tmpPictureDir.path}/${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}_${now.second}_${now.millisecond}.png";
    List<String> args = [
      "-r",
      "-b",
      "-n",
      "-o=$pictureImagePath",
    ];
    await Process.run("/usr/bin/spectacle", args);
    File picture = File(pictureImagePath);
    if(picture.existsSync()) {
      return "file://$pictureImagePath";
    }else {
      return "";
    }
  }

}