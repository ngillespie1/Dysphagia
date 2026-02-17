import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/exercise.dart';

/// Repository for caching exercise videos for offline use
class VideoCacheRepository {
  static const String _boxName = 'video_cache';
  
  final Dio _dio = Dio();
  Box<dynamic>? _box;
  String? _cacheDir;
  
  /// Initialize the cache
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = '${appDir.path}/video_cache';
    
    // Create cache directory if it doesn't exist
    final dir = Directory(_cacheDir!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
  
  /// Check if a video is cached
  Future<bool> isCached(String videoUrl) async {
    if (_box == null) await initialize();
    
    final localPath = _box?.get(videoUrl) as String?;
    if (localPath != null) {
      final file = File(localPath);
      return await file.exists();
    }
    return false;
  }
  
  /// Get local path for a cached video
  Future<String?> getLocalPath(String videoUrl) async {
    if (_box == null) await initialize();
    
    final localPath = _box?.get(videoUrl) as String?;
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        return localPath;
      }
    }
    return null;
  }
  
  /// Download and cache a video
  Future<String?> cacheVideo(
    String videoUrl, {
    void Function(int received, int total)? onProgress,
  }) async {
    if (_box == null) await initialize();
    
    try {
      // Generate local filename from URL
      final filename = _getFilenameFromUrl(videoUrl);
      final localPath = '$_cacheDir/$filename';
      
      // Download the video
      await _dio.download(
        videoUrl,
        localPath,
        onReceiveProgress: onProgress,
      );
      
      // Save mapping in Hive
      await _box?.put(videoUrl, localPath);
      
      return localPath;
    } catch (e) {
      // Failed to cache video
      return null;
    }
  }
  
  /// Cache all videos for a list of exercises
  Future<void> cacheExerciseVideos(
    List<Exercise> exercises, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (_box == null) await initialize();
    
    int completed = 0;
    for (final exercise in exercises) {
      final isCached = await this.isCached(exercise.videoUrl);
      if (!isCached) {
        await cacheVideo(exercise.videoUrl);
      }
      completed++;
      onProgress?.call(completed, exercises.length);
    }
  }
  
  /// Get video path (cached or remote URL)
  Future<String> getVideoPath(String videoUrl) async {
    final localPath = await getLocalPath(videoUrl);
    return localPath ?? videoUrl;
  }
  
  /// Clear all cached videos
  Future<void> clearCache() async {
    if (_box == null) await initialize();
    
    // Delete all files
    final dir = Directory(_cacheDir!);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create();
    }
    
    // Clear Hive mappings
    await _box?.clear();
  }
  
  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    if (_cacheDir == null) await initialize();
    
    final dir = Directory(_cacheDir!);
    if (!await dir.exists()) return 0;
    
    int size = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }
  
  /// Get formatted cache size
  Future<String> getFormattedCacheSize() async {
    final bytes = await getCacheSize();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  String _getFilenameFromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }
    // Fallback to hash
    return '${url.hashCode}.mp4';
  }
}
