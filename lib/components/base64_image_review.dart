import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class Base64ImageReviewPage extends StatefulWidget {

  final String imageBase64;

  const Base64ImageReviewPage({super.key, required this.imageBase64});

  @override
  State<StatefulWidget> createState()  => _Base64ImageReviewPage();
}

class _Base64ImageReviewPage extends State<Base64ImageReviewPage> {
  
  late double _width = 300;
  
  late double _widthHeightRate = 1;

  late Image _image;

  @override
  void initState() {
    super.initState();
    _image = Image.memory(Base64Decoder().convert(widget.imageBase64),
      fit: BoxFit.contain,
    );
    _widthHeightRate = ((_image.width??1)/(_image.height??1));
    _width = 300;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SimpleDialog(
        titlePadding: EdgeInsets.zero,
        title: YaruDialogTitleBar(
          title: Text("图片预览"),
          actions: [
            YaruIconButton(
              icon: Icon(YaruIcons.zoom_in),
              onPressed: () {
                setState(() {
                  if(_width <= 600) {
                    _width = _width + 100;
                  }
                });
              },
            ),
            YaruIconButton(
              icon: Icon(YaruIcons.zoom_out),
              onPressed: () {
                setState(() {
                  if(_width >= 300) {
                    _width = _width - 100;
                  }
                });
              },
            ),
          ],
        ),
        children: [
            SizedBox(
              width: 700,
              height: 500,
              child: Center(
                child: SizedBox(
                  width: _width,
                  height: _width * _widthHeightRate,
                  child: _image,
                ),
              ),
            )
        ],
      ),
    );
  }


}