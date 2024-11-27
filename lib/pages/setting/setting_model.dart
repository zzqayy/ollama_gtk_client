import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk_client/pages/setting/model_setting_page.dart';
import 'package:ollama_gtk_client/src/rapid_ocr/model.dart';
import 'package:ollama_gtk_client/utils/msg_utils.dart';
import 'package:ollama_gtk_client/utils/setting_utils.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class SettingModel extends SafeChangeNotifier {

  //关闭时隐藏页面
  bool closeHideStatus = false;

  //运行的模型
  Model? runningModel;

  //ollama的API地址
  OllamaClient? client;

  //本地模型列表
  List<Model>? modelList = [];

  //模型设置列表
  List<AIModelSettingModel>? modelSettingList = [];

  //模板列表
  List<TemplateModel> templates = [];

  //ocr设置
  OCRModel? ocrModel;

  SettingModel({this.runningModel, this.client, required this.templates, this.closeHideStatus = false, this.modelSettingList, this.ocrModel});

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
    dynamic modelSettingListJsonStr = json['modelSettingList'];
    List<AIModelSettingModel> modelSettingList = [];
    if(modelSettingListJsonStr == null) {

    }else if(modelSettingListJsonStr is List) {
      modelSettingList = modelSettingListJsonStr.map((e) => AIModelSettingModel.fromJson(e)).toList();
    }else {
      var modelSettingListJson = jsonDecode(modelSettingListJsonStr);
      var list = List.from(modelSettingListJson);
      modelSettingList = list.map((e) => AIModelSettingModel.fromJson(e)).toList();
    }
    dynamic ocrModelJsonStr = json['ocrModel'];
    late OCRModel _ocrModel;
    if(ocrModelJsonStr == null) {
      _ocrModel = OCRModel(detPath: "", clsPath: "", recPath: "", szKeyPath: "");
    }else {
      var ocrModelJson = jsonDecode(ocrModelJsonStr);
      _ocrModel = OCRModel.fromJson(ocrModelJson);
    }
    return SettingModel(
        closeHideStatus: closeHideStatus,
        runningModel: Model(model: json['runningModel'] == "" ? null : json['runningModel']),
        client: OllamaClient(baseUrl: json['ollamaBaseUrl'] == "" ? null : json['ollamaBaseUrl']),
        templates: templates,
        modelSettingList: modelSettingList,
        ocrModel: _ocrModel
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> templateJson = templates.map((template) => template.toJson()).toList();
    List<Map<String, dynamic>> modelSettingListJson = modelSettingList?.map((modelSetting) => modelSetting.toJson()).toList()??[];
    return {
      "closeHideStatus": closeHideStatus,
      "runningModel": runningModel?.model??"",
      "ollamaBaseUrl": client?.baseUrl??"",
      "templates": json.encode(templateJson),
      "modelSettingList": json.encode(modelSettingListJson),
      "ocrModel": json.encode(ocrModel??OCRModel(detPath: "", clsPath: "", recPath: "", szKeyPath: ""))
    };
  }

  //初始化
  Future<void> init(BuildContext context) async {
    var settingModel = await SettingUtils.getSettingProperties();
    this.client = settingModel.client;
    this.runningModel = settingModel.runningModel;
    if( settingModel.templates.isEmpty) {
      this.templates = [TemplateModel(templateName: "空模板", assistantDesc: '', templateContent: '', chooseStatus: true)];
    }else {
      int index = settingModel.templates.indexWhere((template) => template.templateName == "空模板");
      if(index == -1) {
        this.templates = [TemplateModel(templateName: "空模板", assistantDesc: '', templateContent: '')];
      }
      this.templates.addAll(settingModel.templates);
    }
    this.ocrModel = settingModel.ocrModel;
    //处理modelList
    refreshModelList(context);
    //处理状态
    closeHideStatus = settingModel.closeHideStatus;
    notifyListeners();
  }

  //修改client
  Future<void> changeClientFromBaseUrl(BuildContext context, {required String? baseUrl}) async {
    client = OllamaClient(
      baseUrl: baseUrl == "" ? null : baseUrl
    );
    await SettingUtils.saveModel(this);
    await refreshModelList(context);
    notifyListeners();
  }

  //修改运行模型
  Future<void> changeRunningModel(BuildContext context, {String? modelName}) async {
    modelName = modelName?.trim();
    runningModel = Model(model: modelName);
    await SettingUtils.saveModel(this);
    if(modelName != null && modelName != "") {
      try{
        await client?.showModelInfo(
            request: ModelInfoRequest(
                model: modelName
            )
        );
      }catch(e) {
        MessageUtils.errorWithContext(context, msg: "模型拉取失败,请自行去命令行拉取");
      }
    }
    notifyListeners();
  }

  //保存模板
  Future<void> saveTemplate(BuildContext context, {required TemplateModel value, int index = -1}) async {
    if(index == 0) {
      MessageUtils.errorWithContext(context, msg: "空模板无法修改.删除");
    } else if(index < 0) {
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
        MessageUtils.errorWithContext(context, msg: "该名称的模板已存在");
      }
    }else {
      templates[index] = value;
      await SettingUtils.saveModel(this);
      notifyListeners();
    }
  }

  //选择模板
  void switchChooseTemplate(BuildContext context, {required SwitchChooseEnum type,
     String? chooseName,
     int? listIndex,
     bool alwaysChoose = false
  }) {
    if(SwitchChooseEnum.listIndex == type && listIndex == null) {
      MessageUtils.errorWithContext(context, msg: "index模式下,未传递index值");
      return;
    }
    if(SwitchChooseEnum.chooseName == type && chooseName == null) {
      MessageUtils.errorWithContext(context, msg: "name模式下,未传递name值");
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
      MessageUtils.errorWithContext(context, msg: "选中的模板不存在");
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
  Future<void> removeTemplate(BuildContext context, int index) async {
    if(index == 0) {
      MessageUtils.errorWithContext(context, msg: "空模板无法修改.删除");
      return;
    }
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

  //保存AI模型设置
  Future<void> saveAIModelSetting(AIModelSettingModel aiModelSettingModel) async {
    int index = modelSettingList?.indexWhere((modelSetting) => modelSetting.modelName == aiModelSettingModel.modelName)??-1;
    if(index < 0) {
      List<AIModelSettingModel> modelList = [aiModelSettingModel];
      modelSettingList = modelList;
      await SettingUtils.saveModel(this);
    }else {
      modelSettingList![index] = aiModelSettingModel;
      await SettingUtils.saveModel(this);
    }
    notifyListeners();
  }

  //刷新模型列表
  Future<void> refreshModelList(BuildContext context) async {
    //处理modelList
    try{
      ModelsResponse? modelsResponse = await client?.listModels();
      modelList = modelsResponse?.models??[];
      runningModel ??= (modelList?.isNotEmpty == true) ? modelList![0] : null;
    }catch(e) {
      modelList = [];
      runningModel = null;
      MessageUtils.errorWithContext(context, msg: "模型拉取失败,请自行去命令行拉取");
      return;
    }
    notifyListeners();
  }

  //显示模型设置页面
  void showModelSettingDialog(BuildContext context) {
    if(runningModel == null) {
      MessageUtils.errorWithContext(context, msg: "无模型选中,无法设置");
      return;
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        AIModelSettingModel? aiModelSettingModel = modelSettingList?.where((modelSetting) => modelSetting.modelName == runningModel?.model).firstOrNull;
        return ModelSettingPage(
          aiModelSettingModel: aiModelSettingModel ??
              AIModelSettingModel(
                  modelName: runningModel?.model ?? "",
                  options: const RequestOptions(
                      temperature: 0.8,
                      topP: 0.9,
                      presencePenalty: 0.0,
                      frequencyPenalty: 0.0)
              ),
          onSubmit: (aiModelSettingModel) async {
            await saveAIModelSetting(aiModelSettingModel);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  //改变ocrModel
  Future<void> changeOcrModel(BuildContext context, {String? detPath,  String? clsPath, String? recPath, String? szKeyPath}) async {
    ocrModel = OCRModel(detPath: detPath??"", clsPath: clsPath??"", recPath: recPath??"", szKeyPath: szKeyPath??"");
    await SettingUtils.saveModel(this);
    notifyListeners();
  }

}

//模板
class TemplateModel {

  //名称
  String templateName;

  //助手描述
  String assistantDesc;

  //对话预处理内容
  String templateContent;

  //选择状态
  bool chooseStatus;

  TemplateModel({required this.templateName,
    required this.assistantDesc,
    required this.templateContent,
    this.chooseStatus = false,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      templateName: json['templateName'],
      assistantDesc: json['assistantDesc']??"",
      templateContent: json['templateContent'],
      chooseStatus: json['chooseStatus'] is bool ? json['chooseStatus'] : false,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "templateName": templateName,
      "assistantDesc": assistantDesc,
      "templateContent": templateContent,
      "chooseStatus": chooseStatus,
    };
  }

}

//切换选择枚举
enum SwitchChooseEnum {
  listIndex,
  chooseName;
}

//模板设置
class AIModelSettingModel {

  //模型名称
  String modelName;

  //设置
  RequestOptions? options;

  AIModelSettingModel({required this.modelName, this.options});

  factory AIModelSettingModel.fromJson(Map<String, dynamic> json) {
    return AIModelSettingModel(
        modelName: json['modelName'],
        options: RequestOptions.fromJson(json['options']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      "modelName": modelName,
      "options": options?.toJson()
    };
  }

}