import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk_client/utils/setting_utils.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class SettingModel extends SafeChangeNotifier {

  //关闭时隐藏页面
  bool closeHideStatus = false;

  //运行的模型
  Model? runningModel;

  //ollama的API地址
  OllamaClient? client;

  //模块id
  List<Model>? modelList = [];

  //模板列表
  List<TemplateModel> templates = [];

  SettingModel({this.runningModel, this.client, required this.templates, this.closeHideStatus = false});

  static SettingModel fromJson(Map<String, dynamic> json) {
    dynamic templatesJsonStr = json['templates'];
    List<TemplateModel> templates = [];
    if(templatesJsonStr == null) {

    }else if(templatesJsonStr is List) {
      templates = templatesJsonStr.map((e) => TemplateModel.fromJson(e)).toList();
    }else {
      var templatesJson = jsonDecode(templatesJsonStr);
      var list = List.from(templatesJson);
      templates = list.map((e) => TemplateModel.fromJson(e)).toList();
    }
    bool closeHideStatus = json['closeHideStatus']??false;
    return SettingModel(
        closeHideStatus: closeHideStatus,
        runningModel: Model(model: json['runningModel'] == "" ? null : json['runningModel']),
        client: OllamaClient(baseUrl: json['ollamaBaseUrl'] == "" ? null : json['ollamaBaseUrl']),
        templates: templates
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> templateJson = templates.map((template) => template.toJson()).toList();
    return {
      "closeHideStatus": closeHideStatus,
      "runningModel": runningModel?.model??"",
      "ollamaBaseUrl": client?.baseUrl??"",
      "templates": json.encode(templateJson),
    };
  }

  //初始化
  Future<void> init() async {
    var settingModel = await SettingUtils.getSettingProperties();
    this.client = settingModel.client;
    this.runningModel = settingModel.runningModel;
    this.templates = settingModel.templates;
    //处理modelList
    ModelsResponse? modelsResponse = await client?.listModels();
    modelList = modelsResponse?.models??[];
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

  //添加模板
  Future<void> addTemplate(TemplateModel value) async {
    var firstTemplate = templates.where((template) => template.templateName == value.templateName).firstOrNull;
    if(firstTemplate == null) {
      if(templates.isEmpty) {
        templates = [value];
      }else {
        templates.add(value);
      }
      await SettingUtils.saveModel(this);
      notifyListeners();
    }else {
      BotToast.showNotification(
        title: (_) => const Text("该名称的模板已存在")
      );
    }
  }

  //编辑模板
  Future<void> editTemplate(TemplateModel value, int index) async {
    templates[index] = value;
    await SettingUtils.saveModel(this);
    notifyListeners();
  }

  //选择模板
  void switchChooseTemplate(BuildContext context, {required SwitchChooseEnum type,
     String? chooseName,
     int? listIndex,
     bool alwaysChoose = false
  }) {
    if(SwitchChooseEnum.listIndex == type && listIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("index模式下,未传递index值"))
      );
      return;
    }
    if(SwitchChooseEnum.chooseName == type && chooseName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("name模式下,未传递name值"))
      );
      return;
    }
    //筛选选中的对象
    int? chooseTemplateIndex;
    for(int index = 0; index < templates.length; index++) {
      var template = templates[index];
      bool nameStatus = true;
      if(chooseName != null) {
        nameStatus = (template.templateName == chooseName);
      }
      bool indexStatus = true;
      if(listIndex != null) {
        indexStatus = (index == listIndex);
      }
      if(nameStatus && indexStatus) {
        chooseTemplateIndex = index;
        break;
      }
    }
    //修改选中兑现值
    if(chooseTemplateIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("选中的模板不存在"))
      );
      return;
    }
    if(alwaysChoose) {
      templates = templates.map((template) {
        template.chooseStatus = false;
        return template;
      }).toList();
      templates[chooseTemplateIndex].chooseStatus = true;
    }else {
      if(true == templates[chooseTemplateIndex].chooseStatus) {
        templates[chooseTemplateIndex].chooseStatus = false;
      }else {
        templates = templates.map((template) {
          template.chooseStatus = false;
          return template;
        }).toList();
        templates[chooseTemplateIndex].chooseStatus = true;
      }
    }
    SettingUtils.saveModel(this);
    notifyListeners();
  }

  //移除模板
  Future<void> removeTemplate(int index) async {
    templates.removeAt(index);
    await SettingUtils.saveModel(this);
    notifyListeners();
  }

  //修改关闭状态
  Future<void> changeCloseHideStatus(bool preCloseHideStatus) async {
    closeHideStatus = preCloseHideStatus;
    await SettingUtils.saveModel(this);
    notifyListeners();
  }

}

//模板
class TemplateModel {

  //名称
  String templateName;

  //内容
  String templateContent;

  //选择状态
  bool chooseStatus;

  TemplateModel({required this.templateName, required this.templateContent, this.chooseStatus = false});

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      templateName: json['templateName'],
      templateContent: json['templateContent'],
      chooseStatus: json['chooseStatus'] is bool ? json['chooseStatus'] : false
    );
  }

  Map<String, Object?> toJson() {
    return {
      "templateName": templateName,
      "templateContent": templateContent,
      "chooseStatus": chooseStatus
    };
  }

}

//切换选择枚举
enum SwitchChooseEnum {
  listIndex,
  chooseName;
}