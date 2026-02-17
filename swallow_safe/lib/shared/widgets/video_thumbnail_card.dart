import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/dimensions.dart';
import '../../core/theme/premium_theme.dart';

/// Hero video card with thumbnail, gradient overlay, and glassmorphic play button
/// PreHab-inspired design with progress indicator
class VideoThumbnailCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? thumbnailUrl;
  final double? progress; // 0.0 to 1.0, null = not started
  final VoidCallback? onTap;
  final double height;
  final bool showDuration;
  final String? duration;

  const VideoThumbnailCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.thumbnailUrl,
    this.progress,
    this.onTap,
    this.height = AppDimensions.videoThumbnailHeightLarge,
    this.showDuration = true,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: PremiumTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail or placeholder
              _buildThumbnail(),
              
              // Gradient overlay
              _buildGradientOverlay(),
              
              // Play button (centered)
              Center(
                child: _GlassPlayButton(
                  isComplete: progress != null && progress! >= 1.0,
                ),
              ),
              
              // Progress indicator (if in progress)
              if (progress != null && progress! > 0 && progress! < 1.0)
                Positioned(
                  top: AppDimensions.spacingM,
                  right: AppDimensions.spacingM,
                  child: _ProgressBadge(progress: progress!),
                ),
              
              // Bottom info
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomInfo(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return Image.network(
        thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumTheme.primaryDark,
            PremiumTheme.primary,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.self_improvement_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: PremiumTheme.heroGradient,
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showDuration && duration != null) ...[
                const SizedBox(width: AppDimensions.spacingM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: AppDimensions.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusPill),
                  ),
                  child: Text(
                    duration!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Glassmorphic play button with blur effect
class _GlassPlayButton extends StatelessWidget {
  final bool isComplete;
  final double size;

  const _GlassPlayButton({
    this.isComplete = false,
    this.size = AppDimensions.playButtonSize,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: PremiumTheme.glassFill,
            shape: BoxShape.circle,
            border: Border.all(
              color: PremiumTheme.glassBorder,
              width: 1.5,
            ),
          ),
          child: Icon(
            isComplete ? Icons.replay_rounded : Icons.play_arrow_rounded,
            size: size * 0.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Small progress badge for top-right corner
class _ProgressBadge extends StatelessWidget {
  final double progress;

  const _ProgressBadge({required this.progress});

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
          decoration: BoxDecoration(
            color: PremiumTheme.accent.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusPill),
          ),
          child: Text(
            '$percentage%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact video thumbnail for lists
class VideoThumbnailCompact extends StatelessWidget {
  final String title;
  final String? thumbnailUrl;
  final bool isComplete;
  final VoidCallback? onTap;

  const VideoThumbnailCompact({
    super.key,
    required this.title,
    this.thumbnailUrl,
    this.isComplete = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.cardHeightMedium,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          boxShadow: PremiumTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              if (thumbnailUrl != null)
                Image.network(
                  thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              else
                _buildPlaceholder(),
              
              // Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: PremiumTheme.heroGradient,
                ),
              ),
              
              // Check mark if complete
              if (isComplete)
                Positioned(
                  top: AppDimensions.spacingS,
                  right: AppDimensions.spacingS,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: PremiumTheme.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              
              // Title
              Positioned(
                left: AppDimensions.spacingM,
                right: AppDimensions.spacingM,
                bottom: AppDimensions.spacingM,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: PremiumTheme.primaryLight,
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 32,
          color: Colors.white38,
        ),
      ),
    );
  }
}
