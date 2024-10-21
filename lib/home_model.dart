import 'package:ollama_gtk/pages/setting/setting_model.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class HomeModel extends SafeChangeNotifier {

  bool connectStatus;

  String version;

  HomeModel({required this.connectStatus, this.version = ""});

  //初始化
  Future<void> init(SettingModel settingModel) async {
    await refreshStatus(settingModel);
  }

  //重新测试连接状态
  Future<void> refreshStatus(SettingModel settingModel) async {
    try{
      var versionResponse = await settingModel.client?.getVersion();
      version = versionResponse?.version??"";
      connectStatus = true;
    }catch(e) {
      connectStatus = false;
    }
    notifyListeners();
  }


}