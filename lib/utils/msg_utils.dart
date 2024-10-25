import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:yaru/theme.dart';

class MessageUtils {

  //错误
  static void error({required String msg, int? millisecondsTimeout}) {
    BotToast.showText(
        text: msg,
        contentColor: YaruColors.adwaitaRed,
        duration: Duration(milliseconds: millisecondsTimeout??3000),
        align: Alignment.topCenter
    );
  }

  //警告
  static void warn({required String msg, int? millisecondsTimeout}) {
    BotToast.showText(
        text: msg,
        contentColor: YaruColors.adwaitaOrange,
        duration: Duration(milliseconds: millisecondsTimeout??3000),
        align: Alignment.topCenter
    );
  }

  //常规
  static void normal({required String msg, int? millisecondsTimeout}) {
    BotToast.showText(
        text: msg,
        contentColor: YaruColors.adwaitaBlue,
        duration: Duration(milliseconds: millisecondsTimeout??3000),
        align: Alignment.topCenter
    );
  }

  //成功
  static void ok({required String msg, int? millisecondsTimeout}) {
    BotToast.showText(
        text: msg,
        contentColor: YaruColors.adwaitaGreen,
        duration: Duration(milliseconds: millisecondsTimeout??3000),
        align: Alignment.topCenter
    );
  }

  //错误
  static void errorWithContext(BuildContext context, {required String msg, int? millisecondsTimeout}) {
    BotToast.showText(
        text: msg,
        contentColor: YaruColors.of(context).error,
        duration: Duration(milliseconds: millisecondsTimeout??3000),
        align: Alignment.topCenter
    );
  }


  //警告
  static void warnWithContext(BuildContext context, {required String msg, int? millisecondsTimeout}) {
    BotToast.showText(
        text: msg,
        contentColor: YaruColors.of(context).warning,
        duration: Duration(milliseconds: millisecondsTimeout??3000),
        align: Alignment.topCenter
    );
  }

  //常规
  static void normalWithContext(BuildContext context, {required String msg, int? millisecondsTimeout}) {
    BotToast.showText(
        text: msg,
        contentColor: YaruColors.of(context).link,
        duration: Duration(milliseconds: millisecondsTimeout??3000),
        align: Alignment.topCenter
    );
  }

  //成功
  static void okWithContext(BuildContext context, {required String msg, int? millisecondsTimeout}) {
    BotToast.showText(
        text: msg,
        contentColor: YaruColors.of(context).success,
        duration: Duration(milliseconds: millisecondsTimeout??3000),
        align: Alignment.topCenter
    );
  }

}