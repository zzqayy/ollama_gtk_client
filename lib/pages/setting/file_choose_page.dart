import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ollama_gtk_client/src/xdg_desktop_portal.dart/lib/xdg_desktop_portal.dart';
import 'package:ollama_gtk_client/utils/msg_utils.dart';

class FileChoosePage extends StatefulWidget {

  //显示标题
  final String title;

  //初始化路径
  final String? initPath;

  //选择完成后返回
  final ValueChanged<String?>? onChoose;

  const FileChoosePage({super.key, required this.title, this.onChoose, this.initPath});

  @override
  State<StatefulWidget> createState() => _FileChoosePageState();

}

class _FileChoosePageState extends State<FileChoosePage> {

  //选择文件
  late File? _chooseFile = null;

  @override
  void initState() {
    super.initState();
    if(widget.initPath != null) {
      File initFile = File(widget.initPath!);
      if(initFile.existsSync()) {
        setState(() {
          _chooseFile = initFile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: Text(_chooseFile?.path??""),
      onTap: () async {
        await openImage(context: context);
        if(widget.onChoose != null) {
          widget.onChoose!(_chooseFile?.path);
        }
      },
    );
  }

  //选择文件
  Future<void> openImage({required BuildContext context}) async {
    var client = XdgDesktopPortalClient();
    try{
      var result = client.fileChooser.openFile(
          title: "选择 ${widget.title}",
          multiple: false,
          directory: false,
          filters: [
            XdgFileChooserFilter('ALL', [
              XdgFileChooserGlobPattern('*.onnx'),
              XdgFileChooserGlobPattern('*.txt'),
            ]),
            XdgFileChooserFilter('onnx', [
              XdgFileChooserGlobPattern('*.onnx'),
              XdgFileChooserMimeTypePattern('image/png')
            ]),
            XdgFileChooserFilter('txt', [
              XdgFileChooserGlobPattern('*.txt'),
            ]),
          ]
      );
      var imageResult = await result.first;
      var fileUri = Uri.decodeFull(imageResult.uris.first);
      if(fileUri.startsWith('file://')) {
        fileUri = fileUri.replaceFirst('file://', '');
      }
      setState(() {
        _chooseFile = File(fileUri);
      });
    }catch(e) {
      MessageUtils.errorWithContext(context, msg: "文件选择未选中");
    }
    await client.close();
  }

}