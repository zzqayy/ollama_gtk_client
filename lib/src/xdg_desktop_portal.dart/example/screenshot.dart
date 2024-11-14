import 'dart:convert';
import 'dart:io';

import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

void main(List<String> args) async {
  var client = XdgDesktopPortalClient();
  try{
    final screenshot = await client.screenshot.screenshot(interactive: true);
    if(screenshot.uri.isNotEmpty) {
      var fileUri = Uri.decodeFull(screenshot.uri);
      if(fileUri.startsWith('file://')) {
        fileUri = fileUri.replaceFirst('file://', '');
      }
      var file = File(fileUri);
      var fileBytes = await file.readAsBytes();
      var base64encode = base64Encode(fileBytes);
      print(base64encode);
    }
  }catch(e) {
    print("截图出错啦, ${e.toString()}");
  }
  await client.close();
}
