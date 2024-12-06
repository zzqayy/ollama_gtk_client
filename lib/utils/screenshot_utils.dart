import 'package:flutter/cupertino.dart';
import 'package:ollama_gtk_client/src/xdg_desktop_portal.dart/lib/src/xdg_desktop_portal_client.dart';
import 'package:ollama_gtk_client/utils/process_utils.dart';
import 'package:platform_linux/platform.dart';
import 'package:yaru/yaru.dart';

import 'msg_utils.dart';

class ScreenshotUtils {

  ///自定义区域截图
  static Future<String> screenshotArea(BuildContext context) async {
    final platform = LocalPlatform();
    String screenshotUri = "";
    if(platform.isLinux) {
      if(platform.isKDE) {
        screenshotUri = await screenshotAreaKDE(context);
      }else if(platform.isCinnamon){
        screenshotUri = await screenshotAreaCinnamon(context);
      }else {
        screenshotUri = await screenshotXdg(context);
      }
      ///统一处理file链接
      if(screenshotUri.isNotEmpty && screenshotUri != "") {
        var fileUri = Uri.decodeFull(screenshotUri);
        if(fileUri.startsWith('file://')) {
          screenshotUri = fileUri.replaceFirst('file://', '');
        }
      }
    }
    return screenshotUri;
  }

  ///KDE截图
  static Future<String> screenshotAreaKDE(BuildContext context) async {
    String screenshotUri = "";
    //kde截图
    try{
      screenshotUri = await ProcessUtils.captureKDEArea();
    }catch(e) {
      MessageUtils.errorWithContext(context, msg: "调用spectacle截图失败,请查看是否有该应用");
      return screenshotUri;
    }finally {
      await YaruWindow.of(context).show();
    }
    return screenshotUri;
  }

  ///Cinnamon截图
  static Future<String> screenshotAreaCinnamon(BuildContext context) async {
    String screenshotUri = "";
    //linuxmint截图
    try{
      screenshotUri = await ProcessUtils.captureCinnamonArea();
    }catch(e) {
      MessageUtils.errorWithContext(context, msg: "调用gnome-screenshot截图失败,请查看是否有该应用");
      return screenshotUri;
    }finally {
      await YaruWindow.of(context).show();
    }
    return screenshotUri;
  }

  ///xdg截图
  static Future<String> screenshotXdg(BuildContext context) async {
    String screenshotUri = "";
    //除了kde其他截图都使用xdg截图接口
    var client = XdgDesktopPortalClient();
    try {
      final screenshot = await client.screenshot.screenshot(interactive: true);
      screenshotUri = screenshot.uri;
    }catch(e) {
      MessageUtils.errorWithContext(context, msg: "截图未完成");
      return screenshotUri;
    }finally {
      await client.close();
      await YaruWindow.of(context).show();
    }
    return screenshotUri;
  }


}