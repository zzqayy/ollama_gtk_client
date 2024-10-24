import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:yaru/yaru.dart';

class ModelSettingPage extends StatefulWidget {
  
  final AIModelSettingModel aiModelSettingModel;

  final ValueChanged<AIModelSettingModel>? onSubmit;

  const ModelSettingPage({super.key, required this.aiModelSettingModel, this.onSubmit});

  @override
  State<StatefulWidget> createState() => _ModelSettingPageState();
}

class _ModelSettingPageState extends State<ModelSettingPage> {

  late double temperature;

  late double topP;

  late double presencePenalty;

  late double frequencyPenalty;


  @override
  void initState() {
    super.initState();
    temperature = widget.aiModelSettingModel.options?.temperature??0.8;
    topP = widget.aiModelSettingModel.options?.topP??0.9;
    presencePenalty = widget.aiModelSettingModel.options?.presencePenalty??0.0;
    frequencyPenalty = widget.aiModelSettingModel.options?.frequencyPenalty??0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const YaruDialogTitleBar(
        title: Text('模型参数设置'),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(kYaruPagePadding),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          YaruTile(
            title: const Text("模型"),
            trailing: Text(widget.aiModelSettingModel.modelName),
          ),
          YaruTile(
            title: const Text("随机性 Temperature"),
            subtitle: const Text("值越大,回复越随机(通常在1.0以内)"),
            trailing: Row(
              children: [
                Slider(
                  min: 0.0,
                  max: 2.0,
                  value: temperature,
                  onChanged: (scale) => setState(() => temperature = double.parse(scale.toStringAsFixed(2))),
                ),
                Text(temperature.toString()),
              ],
            )
          ),
          YaruTile(
              title: const Text("核采样率 top_p"),
              subtitle: const Text("与随机性类似,但不要和随机性一起更改"),
              trailing: Row(
                children: [
                  Slider(
                    min: 0.5,
                    max: 0.95,
                    value: topP,
                    onChanged: (scale) => setState(() => topP = double.parse(scale.toStringAsFixed(2))),
                  ),
                  Text(topP.toString()),
                ],
              )
          ),
          YaruTile(
              title: const Text("话题新鲜度 presence_penalty 在场惩罚"),
              subtitle: const Text("值越大，越有可能扩展到新话题"),
              trailing: Row(
                children: [
                  Slider(
                    min: 0.0,
                    max: 1.0,
                    value: presencePenalty,
                    onChanged: (scale) => setState(() => presencePenalty = double.parse(scale.toStringAsFixed(2))),
                  ),
                  Text(presencePenalty.toString()),
                ],
              )
          ),
          YaruTile(
              title: const Text("频率惩罚度 frequency_penalty 频率惩罚"),
              subtitle: const Text("值越大,越有可能降低重复字词"),
              trailing: Row(
                children: [
                  Slider(
                    min: 0.0,
                    max: 1.0,
                    value: frequencyPenalty,
                    onChanged: (scale) => setState(() => frequencyPenalty = double.parse(scale.toStringAsFixed(2))),
                  ),
                  Text(frequencyPenalty.toString()),
                ],
              )
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            if(widget.onSubmit != null) {
              widget.onSubmit!(
                  AIModelSettingModel(
                    modelName: widget.aiModelSettingModel.modelName,
                    options: RequestOptions(
                      temperature: temperature,
                      topP: topP,
                      presencePenalty: presencePenalty,
                      frequencyPenalty: frequencyPenalty
                    ),
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