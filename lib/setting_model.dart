import 'package:ollama_dart/ollama_dart.dart';

class SettingModel {

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

}