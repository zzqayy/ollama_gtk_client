import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:ollama_gtk_client/src/rapid_ocr/model.dart';
import 'package:ollama_gtk_client/utils/msg_utils.dart';
import 'package:ollama_gtk_client/utils/storage_utils.dart';

//rapidOCR模型
final class RapidOCRModel extends Struct {

  //检测模型(det)模型目录
  external Pointer<Utf8> detPath;

  //方向分类器(cls)目录
  external Pointer<Utf8> clsPath;

  //识别模型(rec)目录
  external Pointer<Utf8> recPath;

  //key路径
  external Pointer<Utf8> szKeyPath;
}

//创建OCRModel
typedef CreateOCRModelNative = RapidOCRModel Function(Pointer<Utf8> szDetModel, Pointer<Utf8> szClsModel, Pointer<Utf8> szRecModel, Pointer<Utf8> szKeyPath);
typedef CreateOCRModelDart = RapidOCRModel Function(Pointer<Utf8> szDetModel, Pointer<Utf8> szClsModel, Pointer<Utf8> szRecModel, Pointer<Utf8> szKeyPath);

//调用翻译
typedef RapidOCRNative = Pointer<Utf8> Function(RapidOCRModel ocrModel, Int32 nThreads, Pointer<Utf8> imagePath);
typedef RapidOCRDart = Pointer<Utf8> Function(RapidOCRModel ocrModel, int nThreads, Pointer<Utf8> imagePath);

//ocr工具
class RapidOCRUtils {

  static const String LIB_SO_PATH = "libRapidOcrOnnx.so";

  ///获取ocr插件目录地址
  static Future<String> getOcrPluginsDirPath() async {
    var pluginsDir = await StorageUtils.getPluginsDir();
    Directory directory = Directory("${pluginsDir.path}/RapidOcrOnnx/lib");
    if(!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory.path;
  }

  ///获取ocr插件文件地址
  static Future<String> getOcrPluginsPath() async {
    String dirPath = await getOcrPluginsDirPath();
    return "$dirPath/$LIB_SO_PATH";
  }

  ///检查ocr插件是否存在
  static Future<bool> checkOcrPluginsExists({String? pluginsPath}) async {
    pluginsPath ??= await getOcrPluginsPath();
    File pluginsFile = File(pluginsPath??"");
    return pluginsFile.existsSync();
  }

  //识别图片
  static Future<String?> ocr({required OCRModel ocrModel, required String imagePath, int processNum = 4}) async {
    try{
      String pluginsPath = await getOcrPluginsPath();
      if(!(await checkOcrPluginsExists(pluginsPath: pluginsPath))) {
        MessageUtils.error(msg: "未找到插件地址");
        return null;
      }
      final dylib = DynamicLibrary.open(pluginsPath);
      //创建对象
      final rapidOCRModelDart = dylib.lookupFunction<CreateOCRModelNative, CreateOCRModelDart>("create_ocr_model");
      final rapidOCRModel = rapidOCRModelDart(
          ocrModel.detPath.toNativeUtf8(),
          ocrModel.clsPath.toNativeUtf8(),
          ocrModel.recPath.toNativeUtf8(),
          ocrModel.szKeyPath.toNativeUtf8()
      );
      final rapidOCR = dylib.lookupFunction<RapidOCRNative, RapidOCRDart>("rapid_ocr");
      final rapidOcrLibPointer = rapidOCR(rapidOCRModel, processNum, imagePath.toNativeUtf8());
      final ocrStr = rapidOcrLibPointer.cast<Utf8>().toDartString();
      calloc.free(rapidOcrLibPointer);
      return ocrStr;
    }catch(e) {
      MessageUtils.error(msg: "OCR失败,原因是: ${e.toString()}");
    }
    return null;
  }
  
}


