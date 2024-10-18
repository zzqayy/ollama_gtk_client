import 'package:ollama_dart/ollama_dart.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class TalkModel extends SafeChangeNotifier {

  TalkModel(this.client);

  //mode名
  Model? runningModel;

  //连接客户端
  final OllamaClient client;

  //模型列表
  List<Model>? modelList;

  //初始化
  Future<void> init() async {
    await initModelList();
  }

  //初始化模型列表
  Future<void> initModelList() async {
    client.listModels().asStream().listen((response) {
      modelList = response.models;
      notifyListeners();
    });
  }
}