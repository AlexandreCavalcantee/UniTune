import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/song.dart';

/// Global, lightweight audio preview player (30s) for quick testing.
class NowPlayingProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Song? _song;
  bool _loading = false;
  String? _error;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;

  NowPlayingProvider() {
    _stateSub = _player.playerStateStream.listen((_) => notifyListeners());
    _posSub = _player.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });
    _durSub = _player.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });
  }

  Song? get song => _song;
  bool get isLoading => _loading;
  String? get error => _error;

  bool get isPlaying => _player.playing;
  Duration get position => _position;
  Duration get duration => _duration;

  Future<void> playPreview(Song song) async {
    if (song.previewUrl == null || song.previewUrl!.isEmpty) {
      _error = 'Preview indisponível.';
      notifyListeners();
      return;
    }

    _error = null;

    // Toggle if it's the same song.
    if (_song?.trackId == song.trackId) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    _song = song;
    _loading = true;
    notifyListeners();

    try {
      await _player.setUrl(song.previewUrl!);
    } catch (_) {
      _error = 'Não foi possível reproduzir o preview.';
      return;
    } finally {
      _loading = false;
      notifyListeners();
    }

    _player.play().catchError((_) {
      _error = 'Não foi possível reproduzir o preview.';
      notifyListeners();
    });
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();

  Future<void> seek(Duration d) => _player.seek(d);

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

