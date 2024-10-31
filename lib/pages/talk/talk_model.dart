import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk_client/home_model.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:ollama_gtk_client/utils/msg_utils.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class TalkModel extends SafeChangeNotifier {

  //连续的作答状态
  bool continuousAnswerStatus = false;

  //当前回答的状态
  TalkHistory? currentTalk;

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
      MessageUtils.errorWithContext(context, msg: "同一时间内只能回答一个问题,请勿重复请求回答");
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
    currentTalk = TalkHistory(talkQuestion: question,
      talkContent: "",
      talkDateTime: DateTime.now(),
      model: settingModel.runningModel?.model??"",
      templateName: templateModel?.templateName,
      templateContent: templateModel?.templateContent,
      modelOptions: (settingModel.modelSettingList??[]).where((model) => model.modelName == (settingModel.runningModel?.model??"")).firstOrNull?.options,
      titleExpanded: false,
      continuousAnswerStatus: continuousAnswerStatus
    );
    notifyListeners();
    List<Message> messageList = [];
    if(continuousAnswerStatus) {
      //如果是连续作答,则加入
      historyList.reversed
          .forEach((e) => messageList.addAll(e.toMessage()));
    }
    messageList.addAll(currentTalk!.toMessage());
    try {
      final generated = settingModel.client?.generateChatCompletionStream(request: GenerateChatCompletionRequest(
          model: settingModel.runningModel!.model!,
          messages: messageList,
          options: currentTalk?.modelOptions
      ));
      await for(final res in generated!) {
        currentTalk!.talkContent += res.message.content??'';
        notifyListeners();
      }
      //回答完成后入库
      List<TalkHistory> newHistoryList = [
        currentTalk!
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
      currentTalk = null;
      notifyListeners();
    }catch(e) {
      MessageUtils.normalWithContext(context, msg: "回答停止");
      return;
    }
    homeModel.changeTalkingStatus(talkStatus: false);
    notifyListeners();
  }

  //清空历史
  void clearHistory({required HomeModel homeModel}) {
    historyList = [];
    notifyListeners();
  }

  //停止作答
  Future<void> stopTalk(BuildContext context, {required SettingModel settingModel, required HomeModel homeModel}) async {
    if(!homeModel.talkingStatus) {
      MessageUtils.errorWithContext(context, msg: "当前不在回答信息无法停止");
      return;
    }
    settingModel.client?.endSession();
    //将内容填充到历史里
    List<TalkHistory> newHistoryList = [
      currentTalk!
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
    currentTalk = null;
    notifyListeners();
    //重新构建client
    await settingModel.changeClientFromBaseUrl(context, baseUrl: settingModel.client?.baseUrl);
    homeModel.changeTalkingStatus(talkStatus: false);
  }

  //改变标题打开状态
  void changeTitleOpenStatus(int index) {
    historyList[index].titleExpanded = !historyList[index].titleExpanded;
    notifyListeners();
  }

  //改变标题打开状态
  void changeCurrentTitleOpenStatus() {
    currentTalk?.titleExpanded = !(currentTalk?.titleExpanded??false);
    notifyListeners();
  }

  //改变作答状态
  void changeContinuousAnswerStatus() {
    continuousAnswerStatus = !continuousAnswerStatus;
    notifyListeners();
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

  //助手描述
  String? assistantDesc;

  //设置
  RequestOptions? modelOptions;

  //打开标记
  bool titleExpanded;

  //连续的作答状态
  bool continuousAnswerStatus = false;

  TalkHistory({required this.talkQuestion,
    required this.talkContent,
    required this.talkDateTime,
    required this.model,
    this.templateName,
    this.templateContent,
    this.assistantDesc,
    this.modelOptions,
    this.titleExpanded = false,
    this.continuousAnswerStatus = false,
  });

  //转换成消息
  List<Message> toMessage() {
    List<Message> messageList = [];
    //构建模板消息
    if((assistantDesc??"") != "") {
      Message templateMessage = Message(role: MessageRole.system, content: templateContent??"");
      messageList.add(templateMessage);
    }
    //构建用户消息
    if(talkQuestion != "") {
      String question = talkQuestion;
      if((templateContent??"") != "" && templateContent!.contains("{{text}}")) {
        question = templateContent?.replaceAll("{{text}}", question)??"";
      }
      Message userQuestionMessage = Message(role: MessageRole.user, content: question);
      messageList.add(userQuestionMessage);
    }
    //构建助手回复消息
    if(talkContent != "") {
      Message assistantMessage = Message(role: MessageRole.assistant, content: talkContent);
      messageList.add(assistantMessage);
    }
    return messageList;
  }

}