//定义对象
class OCRModel {
  //检测模型(det)模型目录
  String detPath;

  //方向分类器(cls)目录
  String clsPath;

  //识别模型(rec)目录
  String recPath;

  //key路径
  String szKeyPath;

  OCRModel({required this.detPath, required this.clsPath, required this.recPath, required this.szKeyPath});

  factory OCRModel.fromJson(Map<String, dynamic> json) {
    return OCRModel(
      detPath: json['detPath']??"",
      clsPath: json['clsPath']??"",
      recPath: json['recPath']??"",
      szKeyPath: json['szKeyPath']??"",
    );
  }

  Map<String, Object?> toJson() {
    return {
      "detPath": detPath,
      "clsPath": clsPath,
      "recPath": recPath,
      "szKeyPath": szKeyPath,
    };
  }

}