import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:yaru/yaru.dart';

class TemplateSettingPage extends StatefulWidget {

  final TemplateModel? templateModel;

  final ValueChanged<TemplateModel>? onSubmit;

  const TemplateSettingPage({super.key, this.templateModel, this.onSubmit});

  @override
  State<StatefulWidget> createState() => _ModelSettingPageState();
}

class _ModelSettingPageState extends State<TemplateSettingPage> {

  late TextEditingController _nameController;
  late TextEditingController _assistantController;
  late TextEditingController _contentController;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.templateModel?.templateName??"");
    _assistantController = TextEditingController(text: widget.templateModel?.assistantDesc??"");
    _contentController = TextEditingController(text: widget.templateModel?.templateContent??"");
  }


  @override
  void dispose() {
    _nameController.dispose();
    _assistantController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const YaruDialogTitleBar(
        title: Text('模板参数设置'),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(kYaruPagePadding),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(hintText: "请输入助手名称"),
              maxLines: 1,
              controller: _nameController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(hintText: "请输入助手设定"),
              maxLines: 5,
              controller: _assistantController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(hintText: "请输入用户输入预处理(回答时,将{{text}}替换为实时输入信息)"),
              maxLines: 5,
              controller: _contentController,
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            if(widget.onSubmit != null) {
              widget.onSubmit!(
                TemplateModel(
                  templateName: _nameController.text,
                  templateContent: _contentController.text,
                  chooseStatus: widget.templateModel?.chooseStatus??false,
                  assistantDesc: _assistantController.text
                )
              );
            }
            Navigator.of(context).pop;
          },
          child: const Text('提交'),
        ),
      ],
    );
  }

}