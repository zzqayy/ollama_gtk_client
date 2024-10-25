# ollama_gtk_client

a flutter app build with ubuntu style

## 开始

使用flutter编写的yaru风味的ollama客户端

特性:
- [x] 对话功能
- [x] 指定模型
- [x] 指定模板
- [x] 调整对话时候的参数

## Flutter Dependencies 说明

| 技术 | 说明                     |
| --- |------------------------|
| provider | 状态管理                   |
| handy_window | 外观                     |
| ollama_dart | ollama的调取实现            |
| bot_toast | 消息通知          |
| flutter_distributor | 打包工具                   |
| flutter_markdown | markdown显示             |
| gtk | Canonical出品的GTK工具集合    |
| yaru | Canonical出品的Ubuntu风味外观 |
| safe_change_notifier | Canonical下的安全的同志管理     |
  

## 打包
安装打包插件

```
dart pub global activate flutter_distributor
```

deb打包
```
flutter_distributor package --platform linux --targets deb
```
