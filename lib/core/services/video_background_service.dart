import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

final RouteObserver<PageRoute<dynamic>> videoRouteObserver =
RouteObserver<PageRoute<dynamic>>();

class VideoBackgroundService {
  VideoBackgroundService._internal() {
    WidgetsBinding.instance.addObserver(_lifecycle);
  }

  static final VideoBackgroundService instance =
  VideoBackgroundService._internal();

  static const String _assetPath = 'assets/videos/splash_video.mp4';

  static const String storageKeyVideoUrl = 'advertise_video_url';
  static const String _keyCachedUrl = 'advertise_video_cached_url';
  static const String _keyCachedPath = 'advertise_video_cached_path';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<void>? _prepareFuture;
  Future<String?>? _downloadFuture;

  static const double soundVolume = 1.0;

  VideoPlayerController? _controller;
  Future<void>? _initFuture;

  final Set<Object> _soundOwners = <Object>{};
  bool _hadOwner = false;
  bool _inBackground = false;
  bool _triedAssetFallback = false;
  late final _LifecycleObserver _lifecycle = _LifecycleObserver(this);

  VideoPlayerController get controller {
    _controller ??= VideoPlayerController.asset(_assetPath);
    return _controller!;
  }

  bool get isReady => _controller?.value.isInitialized ?? false;

  Future<void> prepare() => _prepareFuture ??= _doPrepare();

  Future<void> _doPrepare() async {
    if (_controller != null) return;
    try {
      final url = (await _storage.read(key: storageKeyVideoUrl)) ?? '';
      final cachedUrl = await _storage.read(key: _keyCachedUrl);
      final cachedPath = await _storage.read(key: _keyCachedPath);

      File? cachedFile;
      if (cachedPath != null && cachedPath.isNotEmpty) {
        final f = File(cachedPath);
        if (await f.exists() && await f.length() > 0) cachedFile = f;
      }

      File? toPlay;
      bool upToDate = false;
      if (url.isEmpty) {
        toPlay = cachedFile;
        upToDate = true;
      } else if (cachedFile != null && cachedUrl == url) {
        toPlay = cachedFile;
        upToDate = true;
      } else {
        unawaited(_startDownload(url));
        toPlay = cachedFile;
      }

      if (toPlay != null) {
        _controller = VideoPlayerController.file(toPlay);
        debugPrint('Background video: using ${toPlay.path}');
        if (upToDate) unawaited(_cleanOldFiles(keep: toPlay.path));
      } else {
        debugPrint('Background video: using bundled asset fallback');
      }
    } catch (e) {
      debugPrint('Background video prepare failed: $e');
    }
  }

  Future<String?> _startDownload(String url) =>
      _downloadFuture ??= _download(url).whenComplete(() {
        _downloadFuture = null;
      });

  Future<String?> _download(String url) async {
    final client = http.Client();
    File? tmp;
    try {
      final dir = await _videoDir();
      final ext = url.toLowerCase().contains('.webm') ? 'webm' : 'mp4';
      final target = File('${dir.path}/ad_${url.hashCode.toUnsigned(32).toRadixString(16)}.$ext');
      tmp = File('${target.path}.part');

      final response = await client.send(http.Request('GET', Uri.parse(url)));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final sink = tmp.openWrite();
      int received = 0;
      await response.stream.map((chunk) {
        received += chunk.length;
        return chunk;
      }).pipe(sink);

      final expected = response.contentLength;
      if (received == 0 || (expected != null && expected > 0 && received != expected)) {
        throw Exception('Incomplete download ($received/$expected)');
      }

      if (await target.exists()) await target.delete();
      await tmp.rename(target.path);

      await _storage.write(key: _keyCachedUrl, value: url);
      await _storage.write(key: _keyCachedPath, value: target.path);
      debugPrint('Background video downloaded: ${target.path} ($received bytes)');
      return target.path;
    } catch (e) {
      debugPrint('Background video download failed: $e');
      try {
        if (tmp != null && await tmp.exists()) await tmp.delete();
      } catch (_) {}
      return null;
    } finally {
      client.close();
    }
  }

  Future<Directory> _videoDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/ad_video');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _cleanOldFiles({required String keep}) async {
    try {
      final dir = await _videoDir();
      await for (final e in dir.list()) {
        if (e is File && e.path != keep && !e.path.endsWith('.part')) {
          await e.delete();
        }
      }
    } catch (_) {}
  }

  Future<void> initialize() {
    if (_initFuture != null) return _initFuture!;

    _initFuture = () async {
      await prepare();
      await _doInitialize();
    }();
    return _initFuture!;
  }

  Future<void> _doInitialize() async {
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      await _applySound();
    } catch (e) {
      debugPrint('Background video failed to init: $e');
      if (!_triedAssetFallback) {
        _triedAssetFallback = true;
        try {
          await _storage.delete(key: _keyCachedUrl);
          await _storage.delete(key: _keyCachedPath);
          await _controller?.dispose();
        } catch (_) {}
        _controller = VideoPlayerController.asset(_assetPath);
        return _doInitialize();
      }
    }
  }

  void setSoundActive(Object owner, bool active) {
    final changed =
    active ? _soundOwners.add(owner) : _soundOwners.remove(owner);
    if (active) _hadOwner = true;
    if (changed) scheduleMicrotask(_applySound);
  }

  Future<void> _applySound() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      final soundOn = _soundOwners.isNotEmpty && !_inBackground;
      if (soundOn) {
        await c.setVolume(soundVolume);
        if (!c.value.isPlaying) await c.play();
      } else {
        await c.setVolume(0);
        if (_hadOwner && c.value.isPlaying) await c.pause();
      }
    } catch (e) {
      debugPrint('Background video sound update failed: $e');
    }
  }

  void disposeService() {
    _controller?.dispose();
    _controller = null;
    _initFuture = null;
    _prepareFuture = null;
    _soundOwners.clear();
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  final VideoBackgroundService _service;
  _LifecycleObserver(this._service);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _service._inBackground = true;
      _service._applySound();
    } else if (state == AppLifecycleState.resumed) {
      _service._inBackground = false;
      _service._applySound();
    }
  }
}

mixin VideoSoundMixin<T extends StatefulWidget> on State<T>
implements RouteAware {
  PageRoute<dynamic>? _soundRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _soundRoute) {
      if (_soundRoute != null) videoRouteObserver.unsubscribe(this);
      _soundRoute = route;
      videoRouteObserver.subscribe(this, route);
    }
  }

  void _setSound(bool on) =>
      VideoBackgroundService.instance.setSoundActive(this, on);

  @override
  void didPush() => _setSound(true);

  @override
  void didPopNext() => _setSound(true);

  @override
  void didPushNext() => _setSound(false);

  @override
  void didPop() => _setSound(false);

  @override
  void dispose() {
    videoRouteObserver.unsubscribe(this);
    _setSound(false);
    super.dispose();
  }
}