import 'package:flutter/material.dart';
import 'package:ollama_gtk/home_model.dart';
import 'package:ollama_gtk/home_page_item.dart';
import 'package:ollama_gtk/pages/setting/setting_model.dart';
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
            create: (_) => SettingModel()
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
    await settingModel.init();
    context.read<HomeModel>()
        .init(settingModel);
  }

  @override
  Widget build(BuildContext context) {
    final homeModel = context.watch<HomeModel>();
    final settingModel = context.watch<SettingModel>();
    return YaruMasterDetailPage(
      paneLayoutDelegate: const YaruResizablePaneDelegate(
        initialPaneSize: 280,
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
        ),
        body: menuPageItems[index].pageBuilder(context),
        floatingActionButton: buildFloatingActionButton(context, menuPageItems[index]),
      ),
      appBar: YaruWindowTitleBar(
        title: const Text('Ollama Talk'),
        border: BorderSide.none,
        backgroundColor: YaruMasterDetailTheme.of(context).sideBarColor,
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: YaruMasterTile(
          leading: Icon(YaruIcons.radiobox_filled, color: (true == homeModel.connectStatus) ? Colors.green : Colors.redAccent,),
          title: Text(homeModel.version),
          onTap: () {
            homeModel.refreshStatus(settingModel);
          },
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