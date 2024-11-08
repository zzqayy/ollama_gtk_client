import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ollama_gtk_client/components/expend_text.dart';
import 'package:ollama_gtk_client/components/my_yaru_split_button.dart';
import 'package:ollama_gtk_client/home_model.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:ollama_gtk_client/pages/setting/template_setting_page.dart';
import 'package:ollama_gtk_client/pages/talk/talk_model.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';

class TalkPage extends StatefulWidget {
  const TalkPage({super.key});

  static Widget create(context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TalkModel>(create: (_) => TalkModel())
      ],
      child: const TalkPage(),
    );
  }

  @override
  State<StatefulWidget> createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {


  @override
  Widget build(BuildContext context) {
    final homeModel = context.watch<HomeModel>();
    final talkModel = context.watch<TalkModel>();
    final settingModel = context.watch<SettingModel>();
    return YaruDetailPage(
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    (homeModel.talkingStatus && talkModel.currentTalk != null) ? TalkInfoView(
                      talkingStatus: homeModel.talkingStatus,
                      talkHistory: talkModel.currentTalk!,
                      onCancel: () {
                        talkModel.stopTalk(context, settingModel: settingModel, homeModel: homeModel);
                      },
                      switchTitleExpanded: () {
                        talkModel.changeCurrentTitleOpenStatus();
                      },
                    ) : Container(),
                    talkModel.historyList.isEmpty
                        ? Container()
                        : ListView.builder(
                        shrinkWrap: true,
                        itemCount: talkModel.historyList.length,
                        itemBuilder: (context, index) {
                          return TalkInfoView(
                            talkingStatus: homeModel.talkingStatus,
                            talkHistory: talkModel.historyList[index],
                            onCancel: () {
                              talkModel.stopTalk(context, settingModel: settingModel, homeModel: homeModel);
                            },
                            switchTitleExpanded: () {
                              talkModel.changeTitleOpenStatus(index);
                            },
                          );
                        }),
                  ],
                )
            ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: (Theme.of(context).iconTheme.size ?? 30 + 8),
                  top: 30),
              child: UserQuestionWidget(
                talkingStatus: homeModel.talkingStatus,
                onSubmit: (String? question) {
                  talkModel.talk(context,
                      question: question,
                      settingModel: settingModel,
                      homeModel: homeModel
                  );
                },
                onClearClick: () {
                  talkModel.clearHistory(homeModel: homeModel);
                },
                onStopClick: () {
                  talkModel.stopTalk(context,
                      settingModel: settingModel,
                      homeModel: homeModel
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<TalkModel>();
  }
}

//获取用户提问框
class UserQuestionWidget extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final bool talkingStatus;
  final VoidCallback? onClearClick;
  final VoidCallback? onStopClick;
  final bool continuousAnswerStatus;
  final ValueChanged<bool>? onSwitchContinuous;

  const UserQuestionWidget({super.key,
    required this.onSubmit,
    required this.talkingStatus,
    this.onClearClick,
    this.onStopClick,
    this.continuousAnswerStatus = false,
    this.onSwitchContinuous
  });

  @override
  State<StatefulWidget> createState() => _UserQuestionWidgetState();
}

class _UserQuestionWidgetState extends State<UserQuestionWidget> {

  final TextEditingController _questionTextEditingController =
      TextEditingController(text: "");

  bool userMaxLineStatus = false;

  bool hoverSubmitStatus = false;

  bool continuousAnswerStatus = false;

  @override
  void initState() {
    super.initState();
    continuousAnswerStatus = widget.continuousAnswerStatus;
  }

  @override
  void dispose() {
    _questionTextEditingController.dispose();
    super.dispose();
  }

  ///处理Ctrl+Enter案件
  void _handleKeyDown(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter && HardwareKeyboard.instance.isControlPressed) {
      String submitText = _questionTextEditingController.text;
      _questionTextEditingController.text = "";
      if(!widget.talkingStatus) {
        widget.onSubmit(submitText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingModel = context.watch<SettingModel>();
    return SizedBox(
      height: userMaxLineStatus ? MediaQuery.of(context).size.height - 100 : 200,
      child: Container(
        decoration: BoxDecoration(
            border: Border.fromBorderSide(Theme.of(context)
                .inputDecorationTheme
                .border!
                .borderSide),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Text("模板"),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: settingModel.templates.isEmpty
                          ? Container()
                          : YaruSplitButton.outlined(
                        items: settingModel.templates
                            .map((template) => PopupMenuItem(
                          child: Text(
                            template.templateName,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            settingModel.switchChooseTemplate(context,
                                type: SwitchChooseEnum.chooseName,
                                chooseName: template.templateName,
                                alwaysChoose: true
                            );
                          },
                        ))
                            .toList(),
                        child: Text(settingModel.templates
                            .where((template) =>
                        true == template.chooseStatus)
                            .firstOrNull
                            ?.templateName ??"无"
                        ),
                        onPressed: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return TemplateSettingPage(
                                templateModel: settingModel.templates
                                    .where((template) =>
                                true == template.chooseStatus)
                                    .firstOrNull,
                                onSubmit: (value) {
                                  //提交的模板
                                  int index = settingModel.templates
                                      .indexWhere((template) =>
                                  true == template.chooseStatus);
                                  settingModel.saveTemplate(context, value: value, index: index);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        },
                      )),
                  const Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Text("模型"),
                  ),
                  MyYaruSplitButton.outlined(
                    onPressed: () => settingModel.showModelSettingDialog(context),
                    items: settingModel.modelList!.map((model) => PopupMenuItem(
                      child: Text(model.model??"", overflow: TextOverflow.ellipsis,),
                      onTap: () => settingModel.changeRunningModel(context, modelName:model.model),
                    )).toList(),
                    child: Text(settingModel.runningModel?.model??"未选择"),
                    onOptionsPressed: () async => await settingModel.refreshModelList(context),
                  ),
                  Expanded(child: Container()),
                  YaruCheckButton(
                      value: continuousAnswerStatus,
                      onChanged: (bool? status) {
                        if(widget.onSwitchContinuous != null) {
                          widget.onSwitchContinuous!((status??false));
                        }
                        setState(() {
                          continuousAnswerStatus = (status??false);
                        });
                      },
                      title: Text("连续对话", style: Theme.of(context).textTheme.bodySmall,)
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: widget.talkingStatus
                        ? YaruIconButton(
                      icon: const Icon(
                        YaruIcons.stop,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        if(widget.onStopClick != null) {
                          widget.onStopClick!();
                        }
                      },
                    )
                        : YaruIconButton(
                      icon: const Icon(YaruIcons.trash),
                      onPressed: () {
                        if(widget.onClearClick != null) {
                          widget.onClearClick!();
                        }
                      },
                    ),
                  ),
                  YaruIconButton(
                    icon: userMaxLineStatus ? const Icon(YaruIcons.fullscreen_exit) : const Icon(YaruIcons.fullscreen),
                    onPressed: () {
                      setState(() {
                        userMaxLineStatus = !userMaxLineStatus;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
                child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: _handleKeyDown,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "请输入内容",
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        filled: false,
                      ),
                      controller: _questionTextEditingController,
                      autofocus: true,
                      maxLines: null,
                      readOnly: widget.talkingStatus,
                    )
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                      child: Container()
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                      icon: (true == widget.talkingStatus)
                          ? const Icon(YaruIcons.light_bulb_on,)
                          : const Icon(YaruIcons.send),
                      onPressed: () {
                        String submitText = _questionTextEditingController.text;
                        _questionTextEditingController.text = "";
                        widget.onSubmit(submitText);
                      },
                      onHover: (bool status) {
                        setState(() {
                          hoverSubmitStatus = status;
                        });
                      },
                      label: Text((true == widget.talkingStatus)
                          ? "回答中..."
                          : "发送${hoverSubmitStatus ? " (Ctrl+Enter)" : ""}")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//消息视图
class TalkInfoView extends StatelessWidget {

  final TalkHistory talkHistory;

  final bool hasStopBtnStatus;

  final VoidCallback? onCancel;

  final bool talkingStatus;

  final VoidCallback? switchTitleExpanded;

  const TalkInfoView({super.key, required this.talkHistory, this.hasStopBtnStatus = false, this.onCancel, this.talkingStatus = false, this.switchTitleExpanded});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(YaruIcons.user),
            ),
            Expanded(
                child: Padding(
              padding: kMaterialListPadding,
              child: YaruInfoBadge(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                yaruInfoType: YaruInfoType.success,
                title: ExpandableText(talkHistory.talkQuestion,
                  expanded: talkHistory.titleExpanded,
                  switchExpanded: () {
                    if(switchTitleExpanded != null) {
                      switchTitleExpanded!();
                    }
                  },
                ),
              ),
            ))
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(YaruIcons.chat_text),
            ),
            Expanded(
              child: Padding(
              padding: kMaterialListPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YaruInfoBadge(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    yaruInfoType: YaruInfoType.information,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Markdown(
                          padding: const EdgeInsets.all(8),
                          data: (talkHistory.talkContent == "" && talkingStatus) ? "思考中..." : talkHistory.talkContent,
                          shrinkWrap: true,
                          selectable: true,
                          softLineBreak: true,
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(top: 5),
                              child: Text(talkHistory.templateName??"", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right,),
                            ),
                            Expanded(child: Container()),
                            Padding(padding: const EdgeInsets.only(top: 5),
                              child: Text(talkHistory.model, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right,),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: hasStopBtnStatus
                        ? OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.redAccent
                              ),
                              iconColor: Colors.redAccent,
                              padding: const EdgeInsets.all(2),
                            ),
                            icon: const Icon(
                              YaruIcons.stop,
                            ),
                            onPressed: () {
                              if (onCancel == null) {
                                return;
                              }
                              onCancel!();
                            },
                            label: const Text("停止"),
                          )
                        : Container(),
                  ),
                ],
              ),
            ))
          ],
        ),

      ],
    );
  }
}
