import 'package:flutter/material.dart';
import 'package:ollama_gtk_client/home_model.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:ollama_gtk_client/pages/talk/talk_model.dart';
import 'package:ollama_gtk_client/pages/talk/user/talk_view.dart';
import 'package:ollama_gtk_client/pages/talk/user/user_question_weight.dart';
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
                onSubmit: (UserQuestionModel? questionModel) {
                  talkModel.talk(context,
                      question: questionModel?.question,
                      imageBase64Str: questionModel?.base64Str,
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

