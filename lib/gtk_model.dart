import 'package:flutter/cupertino.dart';
import 'package:ollama_gtk_client/theme.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:yaru/yaru.dart';

///命令行参数启动
class GtkCommandLineModel extends SafeChangeNotifier {

  ///主题色
  String? themeColor;

  ///开启ocr
  bool ocrStatus;

  ///截图
  bool screenshotStatus;

  GtkCommandLineModel({this.themeColor, this.ocrStatus = false, this.screenshotStatus = false});

  ///修改对象
  void changeFromArgs(BuildContext context, List<String> args) {
    ///主题色初始化
    String? themeColor = (args.where((arg) => arg.startsWith("--theme=") || arg.startsWith("-t="))
        .firstOrNull)?.replaceFirst("--theme=", "").replaceFirst("-t=", "").trim();
    this.themeColor = themeColor;
    changeTheme(context, themeColor);
    ///截图初始化
    bool ocrStatus = args.any((arg) => arg == "--ocr" || arg == "-o");
    this.ocrStatus = ocrStatus;
    ///初始化截图
    bool screenshotStatus = args.any((arg) => arg == "--screenshot" || arg == "-s");
    this.screenshotStatus = screenshotStatus;
    notifyListeners();
  }

  ///修改主题色
  Future<void> changeTheme(BuildContext context, String? theme) async {
    if(theme == null) {
      return;
    }
    YaruVariant? yaruVariant = yaruVariantMap[theme];
    if(yaruVariant != null) {
      InheritedYaruVariant.apply(context, yaruVariant);
    }
  }
  
}