import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:xdg_desktop_portal/src/xdg_portal_request.dart';

/// Portal to perform screen casts.
class XdgScreenshotPortal {
  final DBusRemoteObject _object;
  final String Function() _generateToken;

  XdgScreenshotPortal(this._object, this._generateToken);

  /// Get the version of this portal.
  Future<int> getVersion() => _object
      .getProperty('org.freedesktop.portal.Screenshot', 'version',
      signature: DBusSignature('u'))
      .then((v) => v.asUint32());

  ///截图
  /// modal 对话框是否静态
  /// interactive 是否可以自定义截图
  Future<XdgScreenshotPortalScreenResult> screenshot({
    String parentWindow = '',
    bool modal = true,
    bool interactive = false,
  }) async {
    var request = XdgPortalRequest(_object, () async {
      var options = <String, DBusValue>{};
      options['handle_token'] = DBusString(_generateToken());
      options['modal'] = DBusBoolean(modal);
      options['interactive'] = DBusBoolean(interactive);
      var result = await _object.callMethod(
        'org.freedesktop.portal.Screenshot',
        'Screenshot',
        [
          DBusString(parentWindow),
          DBusDict.stringVariant(options),
        ],
        replySignature: DBusSignature('o'),
      );
      return result.returnValues[0].asObjectPath();
    });
    var result = await request.stream.first;
    var uriValue = result['uri'];
    String uri = uriValue?.asString()??'';
    return XdgScreenshotPortalScreenResult(uri: uri);
  }
}

///截图结果
class XdgScreenshotPortalScreenResult {

  ///文件链接
  final String uri;

  XdgScreenshotPortalScreenResult({required this.uri});
}
