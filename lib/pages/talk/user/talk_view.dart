//消息视图
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ollama_gtk_client/components/base64_image_review.dart';
import 'package:ollama_gtk_client/components/expend_text.dart';
import 'package:ollama_gtk_client/pages/talk/talk_model.dart';
import 'package:ollama_gtk_client/utils/msg_utils.dart';
import 'package:yaru/yaru.dart';

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
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 10),
                          child: ExpandableText(talkHistory.talkQuestion,
                            expanded: talkHistory.titleExpanded,
                            switchExpanded: () {
                              if(switchTitleExpanded != null) {
                                switchTitleExpanded!();
                              }
                            },
                          ),
                        ),
                        (talkHistory.imageBase64 == null && talkHistory.imageBase64 == "") ? Container() : GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                            ),
                            width: 100,
                            height: 100,
                            child: Image.memory(Base64Decoder().convert(talkHistory.imageBase64!),
                              fit: BoxFit.contain,
                            ),
                          ),
                          onTap: () {
                            _openImage(context);
                          },
                        ),
                      ],
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

  Future<void> _openImage(BuildContext context) async {
    if(talkHistory.imageBase64 == null || talkHistory.imageBase64 == '') {
      MessageUtils.error(msg: "图片为空");
      return;
    }
    return showDialog(
        context: context,
        builder: (context) {
          return Base64ImageReviewPage(
              imageBase64: talkHistory.imageBase64!
          );
        },
    );
  }
}