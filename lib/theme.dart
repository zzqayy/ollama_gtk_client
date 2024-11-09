import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class InheritedYaruVariant
    extends InheritedNotifier<ValueNotifier<YaruVariant?>> {
  InheritedYaruVariant({
    super.key,
    required super.child,
  }) : super(notifier: ValueNotifier(null));

  static YaruVariant? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedYaruVariant>()!
        .notifier!
        .value;
  }

  static void apply(BuildContext context, YaruVariant variant) {
    context
        .findAncestorWidgetOfExactType<InheritedYaruVariant>()!
        .notifier!
        .value = variant;
  }
}

//
const Map<String, YaruVariant> yaruVariantMap = {
  "orange": YaruVariant.orange,
  "bark": YaruVariant.bark,
  "sage": YaruVariant.sage,
  "olive": YaruVariant.olive,
  "viridian": YaruVariant.viridian,
  "prussianGreen": YaruVariant.prussianGreen,
  "blue": YaruVariant.blue,
  "purple": YaruVariant.purple,
  "magenta": YaruVariant.magenta,
  "red": YaruVariant.red,
  "wartyBrown": YaruVariant.wartyBrown,
  "adwaitaBlue": YaruVariant.adwaitaBlue,
  "adwaitaTeal": YaruVariant.adwaitaTeal,
  "adwaitaGreen": YaruVariant.adwaitaGreen,
  "adwaitaYellow": YaruVariant.adwaitaYellow,
  "adwaitaOrange": YaruVariant.adwaitaOrange,
  "adwaitaRed": YaruVariant.adwaitaRed,
  "adwaitaPink": YaruVariant.adwaitaPink,
  "adwaitaPurple": YaruVariant.adwaitaPurple,
  "adwaitaSlate": YaruVariant.adwaitaSlate,
};
