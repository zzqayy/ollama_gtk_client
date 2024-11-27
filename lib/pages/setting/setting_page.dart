import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk_client/components/my_yaru_split_button.dart';
import 'package:ollama_gtk_client/pages/setting/file_choose_page.dart';
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

  late TabController _tabController;

  bool _templateDelStatus = false;

  static const List<YaruTab> _tabList = const [
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
    YaruTab(
      label: 'OCR配置',
      icon: Icon(YaruIcons.document),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabList.length, vsync: this);
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              tabController: _tabController,
              tabs: _tabList,
            ),
          ),
        ),
        children: [
          SizedBox(
            width: 600,
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _baseSettingWidget(settingModel),
                _cloudSettingWidget(settingModel),
                _templateSettingWidget(settingModel),
                _ocrSettingWidget(settingModel),
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
                        settingModel.saveTemplate(context, value: value);
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
                            settingModel.removeTemplate(context, index);
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
                            settingModel.saveTemplate(context, value: value, index: index);
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
                  await settingModel.changeClientFromBaseUrl(context,
                      baseUrl: value
                  );
                },
                initVal: settingModel.client?.baseUrl ?? "",
                title: "Ollama服务地址设置"
            );
          },
        ),
        ListTile(
          title: const Text("模型"),
          subtitle: Text(settingModel.runningModel?.model??""),
          trailing: MyYaruSplitButton.outlined(
            items: settingModel.modelList!.map((model) => PopupMenuItem(
              child: Text(model.model??"", overflow: TextOverflow.ellipsis,),
              onTap: () {
                settingModel.changeRunningModel(context, modelName: model.model);
              },
            )).toList(),
            child: Text(settingModel.runningModel?.model??"无"),
            onOptionsPressed: () async => await settingModel.refreshModelList(context),
          ),
          onTap: () => settingModel.showModelSettingDialog(context),
        ),
      ],
    );
  }

  Widget _ocrSettingWidget(SettingModel settingModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FileChoosePage(
            title: '检测模型(det)',
            initPath: settingModel.ocrModel?.detPath,
            onChoose: (String? filePath) {
              if(filePath != null) {
                settingModel.changeOcrModel(context,
                  detPath: filePath,
                  clsPath: settingModel.ocrModel?.clsPath,
                  recPath: settingModel.ocrModel?.recPath,
                  szKeyPath: settingModel.ocrModel?.szKeyPath,
                );
              }
            },
          ),
          FileChoosePage(
            title: '方向分类器(cls)',
            initPath: settingModel.ocrModel?.clsPath,
            onChoose: (String? filePath) {
              if(filePath != null) {
                settingModel.changeOcrModel(context,
                  detPath: settingModel.ocrModel?.detPath,
                  clsPath: filePath,
                  recPath: settingModel.ocrModel?.recPath,
                  szKeyPath: settingModel.ocrModel?.szKeyPath,
                );
              }
            },
          ),
          FileChoosePage(
            title: '识别模型(rec)',
            initPath: settingModel.ocrModel?.recPath,
            onChoose: (String? filePath) {
              if(filePath != null) {
                settingModel.changeOcrModel(context,
                  detPath: settingModel.ocrModel?.detPath,
                  clsPath: settingModel.ocrModel?.clsPath,
                  recPath: filePath,
                  szKeyPath: settingModel.ocrModel?.szKeyPath,
                );
              }
            },
          ),
          FileChoosePage(
            title: 'key路径',
            initPath: settingModel.ocrModel?.szKeyPath,
            onChoose: (String? filePath) {
              if(filePath != null) {
                settingModel.changeOcrModel(context,
                  detPath: settingModel.ocrModel?.detPath,
                  clsPath: settingModel.ocrModel?.clsPath,
                  recPath: settingModel.ocrModel?.recPath,
                  szKeyPath: filePath,
                );
              }
            },
          ),
        ],
      ),
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
        onSubmit: (value) {
          onSubmit(value);
          Navigator.of(context).pop();
        },
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