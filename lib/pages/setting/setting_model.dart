import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk/utils/setting_utils.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:yaru/yaru.dart';

class SettingModel extends SafeChangeNotifier {

  //运行的模型
  Model? runningModel;

  //ollama的API地址
  OllamaClient? client;

  SettingModel({this.runningModel, this.client});

  static SettingModel fromJson(Map<String, dynamic> json) {
    return SettingModel(
        runningModel: Model(model: json['runningModel'] == "" ? null : json['runningModel']),
        client: OllamaClient(baseUrl: json['ollamaBaseUrl'] == "" ? null : json['ollamaBaseUrl'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "runningModel": runningModel?.model??"",
      "ollamaBaseUrl": client?.baseUrl??"",
    };
  }

  //初始化
  Future<void> init() async {
    var settingModel = await SettingUtils.getSettingProperties();
    this.client = settingModel.client;
    this.runningModel = settingModel.runningModel;
    notifyListeners();
  }

  //修改client
  Future<void> changeClientFromBaseUrl({required String? baseUrl}) async {
    client = OllamaClient(
      baseUrl: baseUrl == "" ? null : baseUrl
    );
    await SettingUtils.saveModel(this);
    notifyListeners();
  }

  //修改运行模型
  Future<void> changeRunningModel(String? value) async {
    value = value?.trim();
    runningModel = Model(model: value);
    await SettingUtils.saveModel(this);
    if(value != null && value != "") {
      try{
        var showModelInfo = await client?.showModelInfo(
            request: ModelInfoRequest(
                model: value
            )
        );
      }catch(e) {
        BotToast.showNotification(
            title: (_) => const Text("模型未拉取"),
          subtitle: (_) => const Text("请自行在命令行中拉取设备")
        );
      }
    }
    notifyListeners();
  }

}