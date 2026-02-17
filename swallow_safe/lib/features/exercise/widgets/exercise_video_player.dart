import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../data/repositories/video_cache_repository.dart';
import 'exercise_fallback_illustration.dart';

/// Native video player for exercises
/// Auto-loops, no seek bar, no controls (prevents accidental scrubbing)
///
/// Cache-aware: checks [VideoCacheRepository] for a local copy first.
/// If the video can't load (offline, error), shows a beautiful illustrated
/// fallback with written instructions so the patient can still exercise.
class ExerciseVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isMuted;
  final bool isPaused;
  final String? exerciseName;
  final String? instructions;

  const ExerciseVideoPlayer({
    super.key,
    required this.videoUrl,
    this.isMuted = true,
    this.isPaused = false,
    this.exerciseName,
    this.instructions,
  });

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _usedLocalCache = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle video URL change
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initializePlayer();
    }

    // Handle mute toggle
    if (oldWidget.isMuted != widget.isMuted && _isInitialized) {
      _controller.setVolume(widget.isMuted ? 0 : 1);
    }

    // Handle pause/resume
    if (oldWidget.isPaused != widget.isPaused && _isInitialized) {
      if (widget.isPaused) {
        _controller.pause();
      } else {
        _controller.play();
      }
    }
  }

  Future<void> _initializePlayer() async {
    try {
      // Try cached local file first (not on web)
      String? localPath;
      if (!kIsWeb) {
        try {
          final cacheRepo = getIt<VideoCacheRepository>();
          localPath = await cacheRepo.getLocalPath(widget.videoUrl);
        } catch (_) {
          // Cache not initialized yet, fall through to network
        }
      }

      if (localPath != null && !kIsWeb) {
        // Use cached local file
        _controller = VideoPlayerController.file(
          File(localPath),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        _usedLocalCache = true;
      } else {
        // Use network URL
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        _usedLocalCache = false;
      }

      await _controller.initialize();

      // Configure for exercise playback
      await _controller.setLooping(true);
      await _controller.setVolume(widget.isMuted ? 0 : 1);

      if (!widget.isPaused) {
        await _controller.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _disposeController() {
    if (_isInitialized) {
      _controller.dispose();
    }
    _isInitialized = false;
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Show illustrated fallback if we have exercise info, else basic error
      if (widget.exerciseName != null && widget.instructions != null) {
        return ExerciseFallbackIllustration(
          exerciseName: widget.exerciseName!,
          instructions: widget.instructions!,
          onRetry: () {
            setState(() {
              _hasError = false;
              _isInitialized = false;
            });
            _initializePlayer();
          },
        );
      }
      return _ErrorView(onRetry: () {
        setState(() {
          _hasError = false;
          _isInitialized = false;
        });
        _initializePlayer();
      });
    }

    if (!_isInitialized) {
      return const _LoadingView();
    }

    return Stack(
      children: [
        // Video
        Container(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),

        // Cached badge (subtle indicator)
        if (_usedLocalCache)
          Positioned(
            top: 12,
            right: 12,
            child: _CachedBadge(),
          ),
      ],
    );
  }
}

/// Subtle badge indicating the video is playing from local cache
class _CachedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Playing from downloaded cache',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download_done_rounded,
              size: 12,
              color: PremiumTheme.success.withOpacity(0.9),
            ),
            const SizedBox(width: 4),
            Text(
              'Cached',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: PremiumTheme.accent,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white70,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
