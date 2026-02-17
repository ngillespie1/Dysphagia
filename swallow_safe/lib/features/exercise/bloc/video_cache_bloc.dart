import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/exercise.dart';
import '../../../data/repositories/video_cache_repository.dart';

// ─── Events ───

abstract class VideoCacheEvent extends Equatable {
  const VideoCacheEvent();

  @override
  List<Object?> get props => [];
}

/// Preemptively cache all videos for the given exercises (current week)
class CacheExerciseVideos extends VideoCacheEvent {
  final List<Exercise> exercises;

  const CacheExerciseVideos(this.exercises);

  @override
  List<Object?> get props => [exercises];
}

/// Request the resolved video path (local cache or remote URL)
class ResolveVideoPath extends VideoCacheEvent {
  final String videoUrl;

  const ResolveVideoPath(this.videoUrl);

  @override
  List<Object?> get props => [videoUrl];
}

/// Clear the entire video cache
class ClearVideoCache extends VideoCacheEvent {
  const ClearVideoCache();
}

/// Refresh cache stats (size, cached count)
class RefreshCacheStats extends VideoCacheEvent {
  const RefreshCacheStats();
}

// ─── States ───

abstract class VideoCacheState extends Equatable {
  const VideoCacheState();

  @override
  List<Object?> get props => [];
}

class VideoCacheInitial extends VideoCacheState {
  const VideoCacheInitial();
}

class VideoCacheDownloading extends VideoCacheState {
  final int completed;
  final int total;

  const VideoCacheDownloading({required this.completed, required this.total});

  double get progress => total > 0 ? completed / total : 0;

  @override
  List<Object?> get props => [completed, total];
}

class VideoCacheReady extends VideoCacheState {
  final int cachedCount;
  final int totalCount;
  final String formattedSize;

  const VideoCacheReady({
    required this.cachedCount,
    required this.totalCount,
    required this.formattedSize,
  });

  bool get isFullyCached => cachedCount >= totalCount && totalCount > 0;

  @override
  List<Object?> get props => [cachedCount, totalCount, formattedSize];
}

class VideoCacheError extends VideoCacheState {
  final String message;

  const VideoCacheError(this.message);

  @override
  List<Object?> get props => [message];
}

class VideoCacheCleared extends VideoCacheState {
  const VideoCacheCleared();
}

// ─── Bloc ───

class VideoCacheBloc extends Bloc<VideoCacheEvent, VideoCacheState> {
  final VideoCacheRepository _repository;

  VideoCacheBloc({required VideoCacheRepository repository})
      : _repository = repository,
        super(const VideoCacheInitial()) {
    on<CacheExerciseVideos>(_onCacheExerciseVideos);
    on<ClearVideoCache>(_onClearVideoCache);
    on<RefreshCacheStats>(_onRefreshCacheStats);
  }

  Future<void> _onCacheExerciseVideos(
    CacheExerciseVideos event,
    Emitter<VideoCacheState> emit,
  ) async {
    if (event.exercises.isEmpty) return;

    try {
      emit(VideoCacheDownloading(completed: 0, total: event.exercises.length));

      await _repository.cacheExerciseVideos(
        event.exercises,
        onProgress: (completed, total) {
          // We can't emit inside a callback, so we just let it proceed
        },
      );

      // Count how many are cached
      int cachedCount = 0;
      for (final exercise in event.exercises) {
        if (await _repository.isCached(exercise.videoUrl)) {
          cachedCount++;
        }
      }

      final size = await _repository.getFormattedCacheSize();

      emit(VideoCacheReady(
        cachedCount: cachedCount,
        totalCount: event.exercises.length,
        formattedSize: size,
      ));
    } catch (e) {
      emit(VideoCacheError('Failed to cache videos: $e'));
    }
  }

  Future<void> _onClearVideoCache(
    ClearVideoCache event,
    Emitter<VideoCacheState> emit,
  ) async {
    try {
      await _repository.clearCache();
      emit(const VideoCacheCleared());
      // Refresh stats after clearing
      emit(const VideoCacheReady(
        cachedCount: 0,
        totalCount: 0,
        formattedSize: '0 B',
      ));
    } catch (e) {
      emit(VideoCacheError('Failed to clear cache: $e'));
    }
  }

  Future<void> _onRefreshCacheStats(
    RefreshCacheStats event,
    Emitter<VideoCacheState> emit,
  ) async {
    try {
      final size = await _repository.getFormattedCacheSize();
      emit(VideoCacheReady(
        cachedCount: 0,
        totalCount: 0,
        formattedSize: size,
      ));
    } catch (e) {
      emit(const VideoCacheReady(
        cachedCount: 0,
        totalCount: 0,
        formattedSize: '0 B',
      ));
    }
  }
}
