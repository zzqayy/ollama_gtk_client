import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk_client/pages/setting/model_setting_page.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:ollama_gtk_client/pages/setting/template_setting_page.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';

class SettingPage extends StatefulWidget {

  final SettingModel settingModel;

  const SettingPage({super.key, required this.settingModel});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with TickerProviderStateMixin  {

  late TabController tabController;

  bool _templateDelStatus = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    SettingModel settingModel = widget.settingModel;
    return Center(
      child: SimpleDialog(
        titlePadding: EdgeInsets.zero,
        title: YaruDialogTitleBar(
          leading: const Center(
            child: Icon(YaruIcons.settings),
          ),
          title: SizedBox(
            width: 500,
            child: YaruTabBar(
              tabController: tabController,
              tabs: const [
                YaruTab(
                  label: '基础',
                  icon: Icon(YaruIcons.application),
                ),
                YaruTab(
                  label: '服务',
                  icon: Icon(YaruIcons.cloud),
                ),
                YaruTab(
                  label: '模板',
                  icon: Icon(YaruIcons.task_list),
                ),
              ],
            ),
          ),
        ),
        children: [
          SizedBox(
            width: 600,
            height: 400,
            child: TabBarView(
              controller: tabController,
              children: [
                _baseSettingWidget(settingModel),
                _cloudSettingWidget(settingModel),
                _templateSettingWidget(settingModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //基础设置
  Widget _baseSettingWidget(SettingModel settingModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            title: const Text("点击关闭按钮操作"),
            subtitle: Text((true == settingModel.closeHideStatus) ? "隐藏应用" : "关闭应用"),
            trailing: YaruSplitButton.outlined(
              items: [
                PopupMenuItem(
                  child: const Text("关闭应用", overflow: TextOverflow.ellipsis,),
                  onTap: () {
                    settingModel.changeCloseHideStatus(false);
                  },
                ),
                PopupMenuItem(
                  child: const Text("隐藏应用", overflow: TextOverflow.ellipsis,),
                  onTap: () {
                    settingModel.changeCloseHideStatus(true);
                  },
                )
              ],
              child: Text((true == settingModel.closeHideStatus) ? "隐藏应用" : "关闭应用"),
            ),
          ),
        )
      ],
    );
  }

  //模板设置
  Widget _templateSettingWidget(SettingModel settingModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              YaruIconButton(
                icon: const Icon(YaruIcons.plus),
                onPressed: () {
                  showTemplateDialog(
                      context: context,
                      onSubmit: (TemplateModel value) {
                        //提交的模板
                        settingModel.saveTemplate(value: value);
                      });
                },
              ),
              Expanded(child: Container()),
              YaruIconButton(
                icon: (true == _templateDelStatus) ? Icon(YaruIcons.settings, color: YaruColors.of(context).warning,)
                    : const Icon(YaruIcons.settings),
                onPressed: () {
                  setState(() {
                    _templateDelStatus = !_templateDelStatus;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(8),
          child: settingModel.templates.isEmpty
              ? Container()
              : SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: settingModel.templates.length,
                itemBuilder: (context, index) {
                  var template = settingModel.templates[index];
                  return ListTile(
                    title: Text(template.templateName),
                    subtitle: Text(template.assistantDesc.length > 100
                        ? "${template.assistantDesc.substring(0, 100)}..."
                        : template.assistantDesc),
                    trailing: (true == _templateDelStatus) ?
                        YaruIconButton(
                          icon: Icon(YaruIcons.trash, color: YaruColors.of(context).warning,),
                          onPressed: () {
                            settingModel.removeTemplate(index);
                          },
                        ) : YaruIconButton(
                        onPressed: () {
                          settingModel.switchChooseTemplate(context,
                              type: SwitchChooseEnum.listIndex,
                              listIndex: index,
                              alwaysChoose: false
                          );
                        },
                        icon: Icon(true == template.chooseStatus
                            ? YaruIcons.checkbox_checked
                            : YaruIcons.checkbox)),
                    onTap: () {
                      showTemplateDialog(
                          context: context,
                          template: template,
                          onSubmit: (TemplateModel value) {
                            //提交的模板
                            settingModel.saveTemplate(value: value, index: index);
                          });
                    },
                  );
                }),
          ),
        ),),
      ],
    );
  }

  //服务设置
  Widget _cloudSettingWidget(SettingModel settingModel) {
    return Column(
      children: [
        ListTile(
          title: const Text("Ollama地址"),
          subtitle: Text(settingModel.client?.baseUrl??""),
          onTap: () {
            showEditTextDialog(
                context: context,
                onSubmit: (String? value) async {
                  await settingModel.changeClientFromBaseUrl(
                      baseUrl: value
                  );
                },
                initVal: settingModel.client?.baseUrl ?? "",
                title: "Ollama服务地址设置"
            );
          },
        ),
        ListTile(
          title: const Text("当前的模型"),
          subtitle: Text(settingModel.runningModel?.model??""),
          trailing: (settingModel.modelList == null || settingModel.modelList!.isEmpty) ? Container():
          YaruSplitButton.outlined(
            items: settingModel.modelList!.map((model) => PopupMenuItem(
              child: Text(model.model??"", overflow: TextOverflow.ellipsis,),
              onTap: () {
                settingModel.changeRunningModel(model.model);
              },
            )).toList() ,
            child: Text(settingModel.runningModel?.model??"无"),
          ),
          onTap: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                AIModelSettingModel? aiModelSettingModel = settingModel.modelSettingList?.where((modelSetting) => modelSetting.modelName == settingModel.runningModel?.model).firstOrNull;
                return ModelSettingPage(
                    aiModelSettingModel: aiModelSettingModel ??
                        AIModelSettingModel(
                            modelName: settingModel.runningModel?.model ?? "",
                            options: const RequestOptions(
                                temperature: 0.8,
                                topP: 0.9,
                                presencePenalty: 0.0,
                                frequencyPenalty: 0.0)
                        ),
                  onSubmit: (aiModelSettingModel) async {
                      await settingModel.saveAIModelSetting(aiModelSettingModel);
                      Navigator.of(context).pop();
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

//添加,编辑模板
void showTemplateDialog({required BuildContext context,
  required ValueChanged<TemplateModel> onSubmit,
  TemplateModel? template
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return TemplateSettingPage(
        templateModel: template,
        onSubmit: onSubmit,
      );
    },
  );
}



//统一的弹出层
Future<void> showEditTextDialog({required BuildContext context,
  required ValueChanged<String> onSubmit,
  String initVal = "",
  required String title
}) {
  TextEditingController _textController = TextEditingController(text: initVal);
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: YaruDialogTitleBar(
          title: Text(title),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(kYaruPagePadding),
        content: Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            decoration: InputDecoration(hintText: "请输入$title"),
            maxLines: 1,
            controller: _textController,
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () {
            onSubmit(_textController.text);
            Navigator.of(context).pop();
            _textController.dispose();
          }, child: const Text("提交")),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _textController.dispose();
            },
            child: const Text('关闭'),
          ),
        ],
      );
    },
  );
}