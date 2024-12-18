import 'dart:async';
import 'dart:math';

import 'package:dbus/dbus.dart';
import 'package:xdg_desktop_portal/src/xdg_screenshot_portal.dart';

import 'xdg_account_portal.dart';
import 'xdg_background_portal.dart';
import 'xdg_camera_portal.dart';
import 'xdg_documents_portal.dart';
import 'xdg_email_portal.dart';
import 'xdg_file_chooser_portal.dart';
import 'xdg_file_transfer_portal.dart';
import 'xdg_memory_monitor_portal.dart';
import 'xdg_network_monitor_portal.dart';
import 'xdg_notification_portal.dart';
import 'xdg_location_portal.dart';
import 'xdg_open_uri_portal.dart';
import 'xdg_power_profile_monitor_portal.dart';
import 'xdg_print_portal.dart';
import 'xdg_proxy_resolver_portal.dart';
import 'xdg_remote_desktop_portal.dart';
import 'xdg_screen_cast_portal.dart';
import 'xdg_secret_portal.dart';
import 'xdg_settings_portal.dart';
import 'xdg_trash_portal.dart';
import 'xdg_wallpaper_portal.dart';

/// A client that connects to the portals.
class XdgDesktopPortalClient {
  /// The bus this client is connected to.
  final DBusClient _bus;
  final bool _closeBus;

  late final DBusRemoteObject _desktopObject;
  late final DBusRemoteObject _documentsObject;

  /// Portal for obtaining information about the user.
  late final XdgAccountPortal account;

  /// Portal for requesting autostart and background activity.
  late final XdgBackgroundPortal background;

  /// Camera portal.
  late final XdgCameraPortal camera;

  /// Portal to access documents.
  late final XdgDocumentsPortal documents;

  /// Portal to send email.
  late final XdgEmailPortal email;

  /// Portal to request access to files.
  late final XdgFileChooserPortal fileChooser;

  /// Portal to get location information.
  late final XdgLocationPortal location;

  /// Portal to monitor memory.
  late final XdgMemoryMonitorPortal memoryMonitor;

  /// Portal to monitor networking.
  late final XdgNetworkMonitorPortal networkMonitor;

  /// Portal to create notifications.
  late final XdgNotificationPortal notification;

  /// Portal to open URIs.
  late final XdgOpenUriPortal openUri;

  /// Portal to transfer files between applications.
  late final XdgFileTransferPortal fileTransfer;

  /// Portal for power profile monitoring.
  late final XdgPowerProfileMonitorPortal powerProfileMonitor;

  /// Portal for printing.
  late final XdgPrintPortal print;

  /// Portal to use system proxy.
  late final XdgProxyResolverPortal proxyResolver;

  /// Portal to use remote desktop.
  late final XdgRemoteDesktopPortal remoteDesktop;

  /// Portal to perform screen casts.
  late final XdgScreenCastPortal screenCast;

  /// Portal for retrieving application secret.
  late final XdgSecretPortal secret;

  /// Portal to access system settings.
  late final XdgSettingsPortal settings;

  /// Portal for trashing files.
  late final XdgTrashPortal trash;

  /// Portal for setting the desktop wallpaper.
  late final XdgWallpaperPortal wallpaper;

  /// Portal For screenshot
  late final XdgScreenshotPortal screenshot;

  /// Keep track of used request/session tokens.
  final _usedTokens = <String>{};

  /// Creates a new portal client. If [bus] is provided connect to the given D-Bus server.
  XdgDesktopPortalClient({DBusClient? bus})
      : _bus = bus ?? DBusClient.session(),
        _closeBus = bus == null {
    _desktopObject = DBusRemoteObject(_bus,
        name: 'org.freedesktop.portal.Desktop',
        path: DBusObjectPath('/org/freedesktop/portal/desktop'));
    _documentsObject = DBusRemoteObject(_bus,
        name: 'org.freedesktop.portal.Documents',
        path: DBusObjectPath('/org/freedesktop/portal/documents'));
    account = XdgAccountPortal(_desktopObject, _generateToken);
    background = XdgBackgroundPortal(_desktopObject, _generateToken);
    camera = XdgCameraPortal(_desktopObject, _generateToken);
    documents = XdgDocumentsPortal(_documentsObject);
    email = XdgEmailPortal(_desktopObject, _generateToken);
    fileChooser = XdgFileChooserPortal(_desktopObject, _generateToken);
    fileTransfer = XdgFileTransferPortal(_documentsObject);
    location = XdgLocationPortal(_desktopObject, _generateToken);
    memoryMonitor = XdgMemoryMonitorPortal(_desktopObject);
    networkMonitor = XdgNetworkMonitorPortal(_desktopObject);
    notification = XdgNotificationPortal(_desktopObject);
    openUri = XdgOpenUriPortal(_desktopObject, _generateToken);
    powerProfileMonitor = XdgPowerProfileMonitorPortal(_desktopObject);
    print = XdgPrintPortal(_desktopObject);
    proxyResolver = XdgProxyResolverPortal(_desktopObject);
    remoteDesktop = XdgRemoteDesktopPortal(_desktopObject);
    screenCast = XdgScreenCastPortal(_desktopObject);
    secret = XdgSecretPortal(_desktopObject, _generateToken);
    settings = XdgSettingsPortal(_desktopObject);
    trash = XdgTrashPortal(_desktopObject);
    wallpaper = XdgWallpaperPortal(_desktopObject);
    screenshot = XdgScreenshotPortal(_desktopObject, _generateToken);
  }

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  Future<void> close() async {
    await networkMonitor.close();
    if (_closeBus) {
      await _bus.close();
    }
  }

  /// Generate a token for requests and sessions.
  String _generateToken() {
    final random = Random();
    String token;
    do {
      token = 'dart${random.nextInt(1 << 32)}';
    } while (_usedTokens.contains(token));
    _usedTokens.add(token);
    return token;
  }
}
