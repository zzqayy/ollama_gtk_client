import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    final talkModel = context.watch<TalkModel>();
    final settingModel = context.watch<SettingModel>();
    return YaruDetailPage(
      appBar: AppBar(
        actions: [
          YaruIconButton(
            icon: const Icon(YaruIcons.trash),
            onPressed: () {
              talkModel.clearHistory();
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
                  child: talkModel.historyList.isEmpty && (false == talkModel.hasTalk) ? Container() : ListView.builder(
                      shrinkWrap: true,
                      itemCount: talkModel.historyList.length + 1,
                      itemBuilder: (context, index) {
                        if(index == 0) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
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
                                        yaruInfoType: YaruInfoType.important,
                                        title: SelectableText(
                                            talkModel.talkQuestion),
                                      ),
                                    ))
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(padding: EdgeInsets.all(8), child: Icon(YaruIcons.chat_text),),
                                    Expanded(
                                        child: Padding(
                                          padding: kMaterialListPadding,
                                          child: YaruInfoBadge(
                                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                                            yaruInfoType: YaruInfoType.information,
                                            title: SelectableText(
                                                talkModel.talkContent),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          );
                        }else {
                          var item = talkModel.historyList[index - 1];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
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
                                            yaruInfoType: YaruInfoType.important,
                                            title: SelectableText(
                                                item.talkQuestion),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(padding: EdgeInsets.all(8), child: Icon(YaruIcons.chat_text),),
                                    Expanded(
                                        child: Padding(
                                          padding: kMaterialListPadding,
                                          child: YaruInfoBadge(
                                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                                            yaruInfoType: YaruInfoType.information,
                                            title: SelectableText(
                                                item.talkContent),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      }
                    ),
            )),
            Padding(
              padding: EdgeInsets.only(left: (YaruTheme.of(context).theme?.iconTheme.size??30 + 8), top: 30),
              child: UserQuestionWidget(
                onSubmit: (String? question) {
                  talkModel.talk(question, settingModel);
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

  const UserQuestionWidget({super.key, required this.onSubmit});

  @override
  State<StatefulWidget> createState() => _UserQuestionWidgetState();
}

class _UserQuestionWidgetState extends State<UserQuestionWidget> {
  final TextEditingController _questionTextEditingController =
      TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    final talkModel = context.watch<TalkModel>();
    final settingModel = context.watch<SettingModel>();
    return Container(
      decoration: BoxDecoration(
          border: Border.fromBorderSide(YaruTheme.of(context).theme!.inputDecorationTheme.border!.borderSide),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Column(
        children: [
          TextField(
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
            readOnly: talkModel.talkingStatus,
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  settingModel.runningModel?.model ?? "模型未选择",
                  style: YaruTheme.of(context).theme?.textTheme.bodySmall,
                )),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      textStyle:
                          YaruTheme.of(context).theme?.textTheme.bodySmall,
                    ),
                    icon: (true == talkModel.talkingStatus) ? const Icon(YaruIcons.stop, color: Colors.redAccent,)
                        : const Icon(YaruIcons.send),
                    onPressed: () {
                      String submitText = _questionTextEditingController.text;
                      _questionTextEditingController.text = "";
                      widget.onSubmit(submitText);
                    },
                    label: Text((true == talkModel.talkingStatus) ? "回答中..." : "发送")),
              ],
            ),
          )
        ],
      ),
    );
  }
}