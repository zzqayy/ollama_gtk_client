class SettingModel {

  //运行的模型
  String runningModel;

  //ollama的API地址
  String ollamaBaseUrl;

  SettingModel({this.runningModel = "", this.ollamaBaseUrl = ""});

  static SettingModel fromJson(Map<String, dynamic> json) {
    return SettingModel(
        runningModel: json['runningModel'],
        ollamaBaseUrl: json['ollamaBaseUrl']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "runningModel": runningModel,
      "ollamaBaseUrl": ollamaBaseUrl,
    };
  }




}