import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ollama_gtk_client/home_model.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
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
      appBar: AppBar(
        actions: [
          YaruIconButton(
            icon: const Icon(YaruIcons.trash),
            onPressed: () {
              talkModel.clearHistory(homeModel: homeModel);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: talkModel.historyList.isEmpty
                  ? Container()
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: talkModel.historyList.length,
                      itemBuilder: (context, index) {
                        return TalkInfoView(
                          talkingStatus: homeModel.talkingStatus,
                          talkHistory: talkModel.historyList[index],
                          hasStopBtnStatus: (index == 0 && homeModel.talkingStatus),
                          onCancel: () {
                            talkModel.stopTalk(context, settingModel: settingModel, homeModel: homeModel);
                          },
                        );
                      }),
            )),
            Padding(
              padding: EdgeInsets.only(
                  left: (YaruTheme.of(context).theme?.iconTheme.size ?? 30 + 8),
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

  const UserQuestionWidget({super.key, required this.onSubmit, required this.talkingStatus});

  @override
  State<StatefulWidget> createState() => _UserQuestionWidgetState();
}

class _UserQuestionWidgetState extends State<UserQuestionWidget> {
  final TextEditingController _questionTextEditingController =
      TextEditingController(text: "");

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
    return Container(
      decoration: BoxDecoration(
          border: Border.fromBorderSide(YaruTheme.of(context)
              .theme!
              .inputDecorationTheme
              .border!
              .borderSide),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KeyboardListener(
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
            maxLength: 1000,
            maxLines: 3,
            readOnly: widget.talkingStatus,
          )
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("模板"),
                ),
                Padding(
                    padding: const EdgeInsets.all(8),
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
                          )),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("模型"),
                ),
                Expanded(child: YaruSplitButton.outlined(
                  items: settingModel.modelList!.map((model) => PopupMenuItem(
                    child: Text(model.model??"", overflow: TextOverflow.ellipsis,),
                    onTap: () {
                      settingModel.changeRunningModel(model.model);
                    },
                  )).toList() ,
                  child: Text(settingModel.runningModel?.model??"无"),
                ),),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      textStyle:
                          YaruTheme.of(context).theme?.textTheme.bodySmall,
                    ),
                    icon: (true == widget.talkingStatus)
                        ? const Icon(YaruIcons.light_bulb_on,)
                        : const Icon(YaruIcons.send),
                    onPressed: () {
                      String submitText = _questionTextEditingController.text;
                      _questionTextEditingController.text = "";
                      widget.onSubmit(submitText);
                    },
                    label: Text((true == widget.talkingStatus)
                        ? "回答中..."
                        : "发送(Ctrl+Enter)")),
              ],
            ),
          )
        ],
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

  const TalkInfoView({super.key, required this.talkHistory, this.hasStopBtnStatus = false, this.onCancel, this.talkingStatus = false});

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
                title: SelectableText(talkHistory.talkQuestion),
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
              child: YaruInfoBadge(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                yaruInfoType: YaruInfoType.information,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Container()),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: hasStopBtnStatus
                              ? OutlinedButton.icon(
                                  icon: const Icon(
                                    YaruIcons.stop,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    if(onCancel == null) {
                                      return;
                                    }
                                    onCancel!();
                                  },
                                  label: Text("停止回答", style: YaruTheme.of(context).theme?.textTheme.bodySmall?.copyWith(
                                    color: Colors.redAccent
                                  ),),
                                )
                              : Container(),
                        ),
                      ],
                    ),
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
                          child: Text(talkHistory.templateName??"", style: YaruTheme.of(context).theme?.textTheme.bodySmall, textAlign: TextAlign.right,),
                        ),
                        Expanded(child: Container()),
                        Padding(padding: const EdgeInsets.only(top: 5),
                          child: Text(talkHistory.model, style: YaruTheme.of(context).theme?.textTheme.bodySmall, textAlign: TextAlign.right,),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ))
          ],
        ),

      ],
    );
  }
}
