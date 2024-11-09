import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:ollama_gtk_client/home_model.dart';
import 'package:ollama_gtk_client/home_page_item.dart';
import 'package:ollama_gtk_client/pages/setting/setting_model.dart';
import 'package:ollama_gtk_client/pages/setting/setting_page.dart';
import 'package:ollama_gtk_client/theme.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';

class HomePage extends StatefulWidget {
  // ignore: unused_element
  const HomePage({super.key});

  static Widget create(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeModel>(
          create: (_) => HomeModel(
            connectStatus: false
          ),
        ),
        ChangeNotifierProvider<SettingModel>(
            create: (_) => SettingModel(templates: [])
        )
      ],
      child: const HomePage(),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    var settingModel = context.read<SettingModel>();
    await settingModel.init(context);
    await context.read<HomeModel>()
        .init(settingModel);
  }

  Future<void> changeTheme(String? theme) async {
    if(theme == null) {
      return;
    }
    YaruVariant? yaruVariant = yaruVariantMap[theme];
    if(yaruVariant != null) {
      InheritedYaruVariant.apply(context, yaruVariant);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeModel = context.watch<HomeModel>();
    final settingModel = context.watch<SettingModel>();
    return GtkApplication(
      onCommandLine: (args) {
        if(kDebugMode) {
          print('command-line: $args');
        }
        //主题设置配置
        String? themeColor = (args.where((arg) => arg.startsWith("--theme=") || arg.startsWith("-t="))
            .firstOrNull)?.replaceFirst("--theme=", "").replaceFirst("-t=", "").trim();
        changeTheme(themeColor);
      },
      onOpen: (files, hint) {
        if(kDebugMode) {
          print('open ($hint): $files');
        }
      },
      child: YaruMasterDetailPage(
        paneLayoutDelegate: const YaruResizablePaneDelegate(
          initialPaneSize: 200,
          minPageSize: kYaruMasterDetailBreakpoint / 2,
          minPaneSize: 175,
        ),
        length: menuPageItems.length,
        tileBuilder: (context, index, selected, availableWidth) => YaruMasterTile(
          leading: menuPageItems[index].iconBuilder(context, selected),
          title: Text(menuPageItems[index].title),
        ),
        pageBuilder: (context, index) => YaruDetailPage(
          appBar: YaruWindowTitleBar(
            backgroundColor: Colors.transparent,
            border: BorderSide.none,
            leading: Navigator.of(context).canPop() ? const YaruBackButton() : null,
            title: buildTitle(context, menuPageItems[index]),
            actions: buildActions(context, menuPageItems[index]),
            onClose: (context) {
              if(settingModel.closeHideStatus) {
                YaruWindow.of(context).hide();
              }else {
                YaruWindow.of(context).close();
              }
            },
          ),
          body: menuPageItems[index].pageBuilder(context),
          floatingActionButton: buildFloatingActionButton(context, menuPageItems[index]),
        ),
        appBar: YaruWindowTitleBar(
          title: const Text('Ollama对话'),
          border: BorderSide.none,
          backgroundColor: YaruMasterDetailTheme.of(context).sideBarColor,
        ),
        bottomBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: YaruMasterTile(
            leading: Icon(YaruIcons.radiobox_filled, color: (true == homeModel.connectStatus) ? Colors.green : Colors.redAccent,),
            title: const Text("设置"),
            onTap: () {
              showSettingsDialog(context);
            },
          ),
        ),
      ),
    );
  }
}

Widget? buildLeading(BuildContext context, PageItem item) {
  return item.leadingBuilder?.call(context);
}

Widget buildTitle(BuildContext context, PageItem item) {
  return item.titleBuilder?.call(context) ?? Text(item.title);
}

List<Widget>? buildActions(BuildContext context, PageItem item) {
  return item.actionsBuilder?.call(context);
}

Widget? buildFloatingActionButton(BuildContext context, PageItem item) {
  return item.floatingActionButtonBuilder?.call(context);
}

//显示弹出层
Future<void> showSettingsDialog(BuildContext context) {
  final model = context.read<SettingModel>();

  return showDialog(
    context: context,
    builder: (context) {
      return AnimatedBuilder(
        animation: model,
        builder: (context, child) {
          return SettingPage(settingModel: model);
        },
      );
    },
  );
}