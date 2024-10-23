import 'package:flutter/material.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';

class SettingPage extends StatefulWidget {

  final SettingModel settingModel;

  const SettingPage({super.key, required this.settingModel});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  bool editStatus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("Ollama地址"),
          subtitle: Text(widget.settingModel.client?.baseUrl??""),
          onTap: () {
            showEditTextDialog(
                context: context,
                onSubmit: (String? value) async {
                  await widget.settingModel.changeClientFromBaseUrl(
                      baseUrl: value
                  );
                },
                initVal: widget.settingModel.client?.baseUrl ?? "",
                title: "Ollama服务地址设置"
            );
          },
        ),
        ListTile(
          title: const Text("当前的模型"),
          subtitle: Text(widget.settingModel.runningModel?.model??""),
          onTap: () {
            showEditTextDialog(
                context: context,
                onSubmit: (String? value) async {
                  await widget.settingModel.changeRunningModel(value);
                },
                initVal: widget.settingModel.runningModel?.model??"",
                title: "选择模型"
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Text("模板列表"),
              Expanded(child: Container()),
              YaruIconButton(
                icon: const Icon(YaruIcons.document_new),
                onPressed: () {
                  showTemplateDialog(
                      context: context, 
                      onSubmit: (TemplateModel value) { 
                        //提交的模板
                        widget.settingModel.addTemplate(value);
                      });
                },
              ),
              YaruIconButton(
                icon: const Icon(YaruIcons.pen),
                onPressed: () {
                  setState(() {
                    editStatus = !editStatus;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(8),
          child: widget.settingModel.templates.isEmpty
              ? Container()
              : SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.settingModel.templates.length,
                itemBuilder: (context, index) {
                  var template = widget.settingModel.templates[index];
                  return ListTile(
                    title: Text(template.templateName),
                    subtitle: Text(template.templateContent.length > 100
                        ? "${template.templateContent.substring(0, 100)}..."
                        : template.templateContent),
                    trailing: IconButton(
                        onPressed: () {
                          widget.settingModel.chooseTemplates(index);
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
                            widget.settingModel.editTemplate(value, index);
                          });
                    },
                  );
                }),
          ),
        ),
      ],
    );
  }
}

//添加,编辑模板
Future<void> showTemplateDialog({required BuildContext context,
  required ValueChanged<TemplateModel> onSubmit,
  TemplateModel? template
}) {
  TextEditingController _nameController = TextEditingController(text: template?.templateName??"");
  TextEditingController _contentController = TextEditingController(text: template?.templateContent??"");
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const YaruDialogTitleBar(
          title: Text("模板"),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(kYaruPagePadding),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: const InputDecoration(hintText: "请输入名称"),
                  maxLines: 1,
                  controller: _nameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: const InputDecoration(hintText: "请输入内容"),
                  maxLines: 5,
                  controller: _contentController,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () {
            TemplateModel newTmplate = TemplateModel(
                templateName: _nameController.text,
                templateContent: _contentController.text,
              chooseStatus: template?.chooseStatus??false
            );
            onSubmit(newTmplate);
            Navigator.of(context).pop();
            _nameController.dispose();
            _contentController.dispose();
          }, child: const Text("提交")),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nameController.dispose();
              _contentController.dispose();
            },
            child: const Text('关闭'),
          ),
        ],
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