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
      ],
    );
  }
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
          onClose: (context) {
            _textController.dispose();
            Navigator.maybePop(context);
          },
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(kYaruPagePadding),
        content: Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            decoration: const InputDecoration(hintText: "请输入Ollama地址"),
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