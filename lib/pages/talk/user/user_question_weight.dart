//获取用户提问框
import 'dart:convert';
import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ollama_gtk_client/components/my_yaru_split_button.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:ollama_gtk_client/pages/setting/template_setting_page.dart';
import 'package:ollama_gtk_client/src/xdg_desktop_portal.dart/lib/xdg_desktop_portal.dart';
import 'package:ollama_gtk_client/utils/env_utils.dart';
import 'package:ollama_gtk_client/utils/msg_utils.dart';
import 'package:ollama_gtk_client/utils/process_utils.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';

//用户model
class UserQuestionModel {

  //问题
  String? question;

  //图片
  String? base64Str;

  UserQuestionModel({this.question, this.base64Str});

}

class UserQuestionWidget extends StatefulWidget {
  //提交内容
  final ValueChanged<UserQuestionModel> onSubmit;
  //聊天状态
  final bool talkingStatus;
  //清除按钮
  final VoidCallback? onClearClick;
  //停止按钮
  final VoidCallback? onStopClick;
  //连续回答状态
  final bool continuousAnswerStatus;
  //切换连续回答状态
  final ValueChanged<bool>? onSwitchContinuous;

  const UserQuestionWidget({super.key,
    required this.onSubmit,
    required this.talkingStatus,
    this.onClearClick,
    this.onStopClick,
    this.continuousAnswerStatus = false,
    this.onSwitchContinuous,
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

  //返回的对象
  late File? _chooseFile;

  @override
  void initState() {
    super.initState();
    continuousAnswerStatus = widget.continuousAnswerStatus;
    _chooseFile = null;
  }

  @override
  void dispose() {
    _questionTextEditingController.dispose();
    super.dispose();
  }

  //提交
  Future<void> _submit() async {
    if(!widget.talkingStatus) {
      String _questionText = _questionTextEditingController.text;
      //清除消息
      _questionTextEditingController.text = "";
      String? base64Str = null;
      if(_chooseFile != null) {
        var fileBytes = await _chooseFile!.readAsBytes();
        base64Str = base64Encode(fileBytes);
        setState(() {
          _chooseFile = null;
        });
      }
      widget.onSubmit(
          UserQuestionModel(
              question: _questionText,
              base64Str: base64Str
          )
      );
    }
  }

  ///处理Ctrl+Enter案件
  void _handleKeyDown(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter && HardwareKeyboard.instance.isControlPressed) {
      _submit();
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
                  IconButton(
                      onPressed: () async {
                        await screenshot2Base64(context: context);
                      },
                      icon: Icon(YaruIcons.camera_photo)
                  ),
                  IconButton(
                      onPressed: () async {
                        await openImage(context: context);
                      },
                      icon: Icon(YaruIcons.folder_open)
                  ),
                  _chooseFile == null ? Container() : SizedBox(
                    width: 200,
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                              onPressed: () {
                                showCapture();
                              },
                              child: Text((_chooseFile?.path??"").length > 10 ? "${(_chooseFile?.path??"").substring((_chooseFile?.path??"").length - 10)}..." : (_chooseFile?.path??""),
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                          ),
                        ),
                        IconButton(onPressed: (){
                          setState(() {
                            _chooseFile = null;
                          });
                        }, icon: Icon(YaruIcons.edit_clear))
                      ],
                    ),
                  ),
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
                        _submit();
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

  //截图
  Future<void> screenshot2Base64({required BuildContext context}) async {
    await YaruWindow.of(context).hide();
    Future.delayed(Duration(milliseconds: 600), () async {
      var de = EnvUtils.getDEUpperCase();
      String? screenshotUri = null;
      if("KDE" == de) {
        //kde直接调用spectacle
        try{
          screenshotUri = await ProcessUtils.captureKDEArea();
        }catch(e) {
          MessageUtils.errorWithContext(context, msg: "调用spectacle截图失败,请查看是否有该应用");
        }
      }else {
        //除了kde其他截图都使用xdg截图接口
        var client = XdgDesktopPortalClient();
        try {
          final screenshot = await client.screenshot.screenshot(interactive: true);
          screenshotUri = screenshot.uri;
        }catch(e) {
          MessageUtils.errorWithContext(context, msg: "截图未完成");
        }finally {
          await client.close();
        }
      }
      if(screenshotUri != null && screenshotUri.isNotEmpty) {
        var fileUri = Uri.decodeFull(screenshotUri);
        if(fileUri.startsWith('file://')) {
          fileUri = fileUri.replaceFirst('file://', '');
        }
        setState(() {
          _chooseFile = File(fileUri);
        });
      }
      await YaruWindow.of(context).show();
    });

  }

  //选择文件
  Future<void> openImage({required BuildContext context}) async {
    var client = XdgDesktopPortalClient();
    try{
      var result = client.fileChooser.openFile(
          title: "选择图片",
          multiple: false,
          directory: false,
          filters: [
            XdgFileChooserFilter('JPG Image', [
              XdgFileChooserGlobPattern('*.jpg'),
              XdgFileChooserGlobPattern('*.jpeg'),
              XdgFileChooserMimeTypePattern('image/jpeg')
            ]),
            XdgFileChooserFilter('PNG Image', [
              XdgFileChooserGlobPattern('*.png'),
              XdgFileChooserMimeTypePattern('image/png')
            ]),
            XdgFileChooserFilter('SVG Image', [
              XdgFileChooserGlobPattern('*.svg'),
              XdgFileChooserMimeTypePattern('application/x-svg')
            ]),
          ]
      );
      var imageResult = await result.first;
      var fileUri = Uri.decodeFull(imageResult.uris.first);
      if(fileUri.startsWith('file://')) {
        fileUri = fileUri.replaceFirst('file://', '');
      }
      setState(() {
        _chooseFile = File(fileUri);
      });
    }catch(e) {
      MessageUtils.errorWithContext(context, msg: "文件选择未选中");
    }
    await client.close();
  }

  //显示图片
  void showCapture() {
    if(_chooseFile == null) {
      MessageUtils.errorWithContext(context, msg: "没有文件需要查看");
      return;
    }
    var client = XdgDesktopPortalClient();
    try{
      client.openUri.openFile(ResourceHandle.fromFile(_chooseFile!.openSync()), writable: false);
    }catch(e) {
      MessageUtils.errorWithContext(context, msg: "打开文件失败");
    }finally {
      client.close();
    }
  }

}