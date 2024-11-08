import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ollama_gtk_client/pages/talk/talk_page.dart';
import 'package:yaru/yaru.dart';

//copyFrom yaru.dart项目
class PageItem {

  const PageItem({
    required this.title,
    this.leadingBuilder,
    this.titleBuilder,
    this.actionsBuilder,
    required this.pageBuilder,
    required this.iconBuilder,
    this.floatingActionButtonBuilder,
    this.supportedLayouts = const {YaruMasterDetailPage, YaruNavigationPage},
  });

  final String title;
  final WidgetBuilder? leadingBuilder;
  final WidgetBuilder? titleBuilder;
  final List<Widget> Function(BuildContext context)? actionsBuilder;
  final WidgetBuilder pageBuilder;
  final WidgetBuilder? floatingActionButtonBuilder;
  final Widget Function(BuildContext context, bool selected) iconBuilder;
  final Set<Type> supportedLayouts;

}

//菜单
final menuPageItems = <PageItem>[
  PageItem(
      title: '对话',
      pageBuilder: (context) => TalkPage.create(context),
      iconBuilder: (context, selected) => const Icon(YaruIcons.chat_bubble),
  ),
];