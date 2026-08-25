import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

enum AppUpdateState {
  idle,
  checking,
  downloading,
  readyToRestart,
  upToDate,
  error,
}

class UpdateService extends ChangeNotifier {
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  AppUpdateState _state = AppUpdateState.idle;
  AppUpdateState get state => _state;

  bool get isChecking => _state == AppUpdateState.checking;
  bool get isDownloading => _state == AppUpdateState.downloading;
  bool get isUpdateReady => _state == AppUpdateState.readyToRestart;

  static const String appVersion = 'v1.0.4';

  int? _currentPatch;
  int? get currentPatch => _currentPatch;

  String get displayVersion {
    if (_currentPatch != null && _currentPatch! > 0) {
      return 'v1.0.${4 + _currentPatch!}';
    }
    return appVersion;
  }

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  UpdateService() {
    _init();
  }

  Future<void> _init() async {
    try {
      _currentPatch = await _updater.readCurrentPatch().then((p) => p?.number);
      notifyListeners();
    } catch (_) {}
    // Uygulama açılışında sessizce kontrol et
    checkForUpdates(silent: true);
  }

  Future<void> checkForUpdates({bool silent = false}) async {
    if (_state == AppUpdateState.checking || _state == AppUpdateState.downloading) return;

    if (!silent) {
      _state = AppUpdateState.checking;
      _statusMessage = 'Güncellemeler denetleniyor...';
      notifyListeners();
    }

    try {
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        _state = AppUpdateState.downloading;
        _statusMessage = 'Yeni güncelleme indiriliyor...';
        notifyListeners();

        await _updater.update();

        _state = AppUpdateState.readyToRestart;
        _statusMessage = '✨ Güncelleme yüklendi! Uygulamayı kapatıp açarak yenilikleri kullanabilirsiniz.';
        notifyListeners();
      } else {
        _state = AppUpdateState.upToDate;
        _statusMessage = 'Uygulamanız en güncel sürümde.';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Shorebird update check error: $e');
      _state = AppUpdateState.error;
      _statusMessage = 'Güncelleme kontrolü yapılamadı.';
      notifyListeners();
    }
  }

  void dismissUpdateBanner() {
    _state = AppUpdateState.idle;
    notifyListeners();
  }
}
