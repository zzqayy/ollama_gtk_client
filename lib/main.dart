import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:ollama_gtk_client/home.dart';
import 'package:ollama_gtk_client/theme.dart';
import 'package:ollama_gtk_client/utils/process_utils.dart';
import 'package:platform_linux/platform.dart';
import 'package:yaru/yaru.dart';

final platform = LocalPlatform();
int? cpuProcessNum = ProcessUtils.getProcessNum();
Future<void> main() async {
  await YaruWindowTitleBar.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();

  runApp(
    InheritedYaruVariant(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return YaruTheme(
      data: YaruThemeData(
        variant: InheritedYaruVariant.of(context),
      ),
      builder: (context, yaru, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ollama Client',
          theme: yaru.theme,
          darkTheme: platform.isLinux ? yaru.darkTheme : ThemeData(
              fontFamily: "MiSans",
              colorScheme: ColorScheme.dark(
                  primary: Colors.blueAccent
              )
          ),
          highContrastTheme: yaruHighContrastLight,
          highContrastDarkTheme: yaruHighContrastDark,
          builder: (context, child) {
            child = botToastBuilder(context,child);
            return child;
          },
          navigatorObservers: [BotToastNavigatorObserver()],
          home: HomePage.create(context),
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
              PointerDeviceKind.trackpad,
            },
          ),
        );
      },
    );
  }
}
