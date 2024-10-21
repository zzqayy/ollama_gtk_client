import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk/pages/setting/setting_model.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class TalkModel extends SafeChangeNotifier {

  //是否已经开启对话
  bool hasTalk = false;

  //对话状态
  bool talkingStatus = false;

  //当前对话的问题
  String talkQuestion = "";

  //当前对话的回答内容
  String talkContent = "";

  //问答历史
  List<TalkHistory> historyList = [];

  TalkModel();

  //开始询问
  Future<void> talk(String? question, SettingModel settingModel) async {
    if(talkingStatus) {
      BotToast.showNotification(
        title: (_) =>  const Text("正在回答信息,请勿重复点击")
      );
      return;
    }
    talkingStatus = true;
    notifyListeners();
    if(question == null) {
      talkingStatus = false;
      notifyListeners();
      return;
    }
    if(hasTalk) {
      historyList.add(TalkHistory(talkQuestion: talkQuestion, talkContent: talkContent));
      talkQuestion = "";
      talkContent = "";
      notifyListeners();
    }
    notifyListeners();
    hasTalk = true;
    talkQuestion = question;
    notifyListeners();
    final stream = settingModel.client?.generateCompletionStream(request: GenerateCompletionRequest(
        model: settingModel.runningModel!.model!,
        prompt: talkQuestion,
    ));
    await for(final res in stream!) {
      talkContent += res.response??'';
      notifyListeners();
    }
    talkingStatus = false;
    notifyListeners();
  }

}

//回答历史
class TalkHistory {

  //对话的问题
  String talkQuestion;

  //回答内容
  String talkContent;

  TalkHistory({required this.talkQuestion, required this.talkContent});

}