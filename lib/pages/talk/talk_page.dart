import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_gtk/pages/talk/talk_model.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';

class TalkPage extends StatefulWidget {
  const TalkPage({super.key});

  static Widget create(context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TalkModel>(
            create: (_) => TalkModel(OllamaClient()))
      ],
      child: const TalkPage(),
    );
  }

  @override
  State<StatefulWidget> createState() => _TalkPageState();

  //创建右侧功能区域
  static createActions(BuildContext context) {
    return [
      YaruIconButton(
        icon: const Icon(YaruIcons.pen),
        onPressed: () {

        },
      ),
    ];
  }
}

class _TalkPageState extends State<TalkPage> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<TalkModel>();
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(
        titleSpacing: 0,
        centerTitle: true,
        title: YaruIconButton(
            icon: Icon(YaruIcons.settings)
        ),
      ),
      children: [
        SizedBox(
          height: 300,
          width: 450,
          child: Center(
            child: Text("测试"),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<TalkModel>().init();
  }
}
