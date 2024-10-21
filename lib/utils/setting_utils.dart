import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import '/utils/storage_utils.dart';

///属性工具
class SettingUtils {

  ///设置文件名
  static const String SETTING_NAME = "setting.json";

  ///获取配置文件
  static Future<File> getSettingPropertiesFile() async {
    var appConfigDir = await StorageUtils.getAppConfigDir();
    File settingFile = File("${appConfigDir.path}/$SETTING_NAME");
    if(!settingFile.existsSync()) {
      ///如果文件存在则加载文件配置
      SettingModel settingModel = SettingModel();
      String jsonString = json.encode(settingModel);
      settingFile = await settingFile.writeAsString(jsonString);
    }
    return settingFile;
  }

  ///获取配置
  static Future<SettingModel> getSettingProperties() async {
    var settingFile = await getSettingPropertiesFile();
    var settingString = await settingFile.readAsString();
    Map<String, dynamic> jsonDecode = json.decode(settingString);
    return SettingModel.fromJson(jsonDecode);
  }

  ///保存配置
  static Future<void> saveModel(SettingModel model) async {
    File propertiesFile = await getSettingPropertiesFile();
    String jsonString = json.encode(model);
    await propertiesFile.writeAsString(jsonString);
  }

}