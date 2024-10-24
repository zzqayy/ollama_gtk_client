import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk_client/home_model.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class TalkModel extends SafeChangeNotifier {

  //问答历史
  List<TalkHistory> historyList = [];

  TalkModel();

  //开始询问
  Future<void> talk(BuildContext context,
      {required String? question,
      required SettingModel settingModel,
      required HomeModel homeModel}) async {
    question = question?.trim();
    if(homeModel.talkingStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("同一时间内只能回答一个问题,请勿重复请求回答"))
      );
      return;
    }
    if(question == null) {
      homeModel.changeTalkingStatus(talkStatus: false);
      notifyListeners();
      return;
    }
    homeModel.changeTalkingStatus(talkStatus: true);
    notifyListeners();

    TemplateModel? templateModel = settingModel.templates.where((template) => template.chooseStatus).firstOrNull;
    TalkHistory newTalk = TalkHistory(talkQuestion: question,
      talkContent: "",
      talkDateTime: DateTime.now(),
      model: settingModel.runningModel?.model??"",
      templateName: templateModel?.templateName,
      templateContent: templateModel?.templateContent
    );
    List<TalkHistory> newHistoryList = [
      newTalk
    ];
    if(historyList.isNotEmpty) {
      var historyListSize = historyList.length;
      for(int i = 0; i < historyListSize; i++) {
        var history = historyList[i];
        newHistoryList.add(history);
      }
    }
    newHistoryList.sort((a, b) => b.talkDateTime.compareTo(a.talkDateTime));
    historyList = newHistoryList;
    notifyListeners();
    List<Message> messageList = [];
    for (var history in newHistoryList.reversed) {
      //构建模板消息
      if(history.templateContent != null && history.templateContent!.isEmpty) {
        Message templateMessage = Message(role: MessageRole.system, content: history.templateContent??"");
        messageList.add(templateMessage);
      }
      //构建用户消息
      if(history.talkQuestion != "") {
        Message userQuestionMessage = Message(role: MessageRole.user, content: history.talkQuestion);
        messageList.add(userQuestionMessage);
      }
      //构建助手回复消息
      if(history.talkContent != "") {
        Message assistantMessage = Message(role: MessageRole.assistant, content: history.talkContent);
        messageList.add(assistantMessage);
      }
    }
    try {
      final generated = settingModel.client?.generateChatCompletionStream(request: GenerateChatCompletionRequest(
          model: settingModel.runningModel!.model!,
          messages: messageList
      ));
      await for(final res in generated!) {
        // newTalk.talkContent += res.message.content??'';
        // historyList[0] = newTalk;
        historyList[0].talkContent += res.message.content??'';
        notifyListeners();
      }
    }catch(e) {
      if(kDebugMode) {
        print("回答停止: ${e.toString()}");
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("回答停止"))
      );
      return;
    }
    homeModel.changeTalkingStatus(talkStatus: false);
    notifyListeners();
  }

  //清空历史
  void clearHistory({required HomeModel homeModel}) {
    if(!homeModel.talkingStatus) {
      historyList = [];
    }else {
      var newTalk = historyList[0];
      historyList = [newTalk];
    }
    notifyListeners();
  }

  //停止作答
  Future<void> stopTalk(BuildContext context, {required SettingModel settingModel, required HomeModel homeModel}) async {
    if(!homeModel.talkingStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("当前不在回答信息无法停止"))
      );
      return;
    }
    settingModel.client?.endSession();
    //重新构建client
    await settingModel.changeClientFromBaseUrl(baseUrl: settingModel.client?.baseUrl);
    homeModel.changeTalkingStatus(talkStatus: false);
  }

}

//回答历史
class TalkHistory {

  //对话的问题
  String talkQuestion;

  //回答内容
  String talkContent;

  //回答时间
  DateTime talkDateTime;

  //回答的模型
  String model;

  //模板名称
  String? templateName;

  //模板内容
  String? templateContent;

  TalkHistory({required this.talkQuestion, required this.talkContent, required this.talkDateTime, required this.model, this.templateName, this.templateContent});

}