// widgets/video_picker_widget.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class VideoPickerWidget extends ConsumerStatefulWidget {
  final VoidCallback onPickVideo;
  final File? selectedVideo;
  final VoidCallback? onClearVideo;
  final String? videoName;

  const VideoPickerWidget({
    super.key,
    required this.onPickVideo,
    this.selectedVideo,
    this.onClearVideo,
    this.videoName,
  });

  @override
  ConsumerState<VideoPickerWidget> createState() => _VideoPickerWidgetState();
}

class _VideoPickerWidgetState extends ConsumerState<VideoPickerWidget> {
  Uint8List? _thumbnailBytes;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  @override
  void didUpdateWidget(covariant VideoPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedVideo != oldWidget.selectedVideo) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    if (widget.selectedVideo == null) {
      setState(() => _thumbnailBytes = null);
      return;
    }

    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: widget.selectedVideo!.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 50,
      );
      setState(() => _thumbnailBytes = bytes);
    } catch (e) {
      setState(() => _thumbnailBytes = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final isVideoSelected = widget.selectedVideo != null;

    return GestureDetector(
      onTap: widget.onPickVideo,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: isVideoSelected ? 1.5 : 1,
            color: isVideoSelected
                ? const Color(0xFFFE2C55)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          boxShadow: isVideoSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFE2C55).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Thumbnail or Placeholder
            if (_thumbnailBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.memory(
                  _thumbnailBytes!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isVideoSelected ? Icons.video_file : Icons.upload_file,
                      size: 32,
                      color: isVideoSelected
                          ? const Color(0xFFFE2C55)
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isVideoSelected ? 'Video Ready' : 'Upload Video',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isVideoSelected
                            ? const Color(0xFFFE2C55)
                            : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                      ),
                    ),
                    if (!isVideoSelected) const SizedBox(height: 2),
                    if (!isVideoSelected)
                      Text(
                        'MP4 up to 60s',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              ),

            // Overlay for selected video info
            if (isVideoSelected && widget.videoName != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.8)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(9),
                      bottomRight: Radius.circular(9),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        color: isDark
                            ? AppColors.pureWhite
                            : AppColors.pureBlack,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.videoName!,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.pureWhite
                                : AppColors.pureBlack,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.onClearVideo != null)
                        GestureDetector(
                          onTap: widget.onClearVideo,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.pureWhite
                                  : AppColors.pureBlack,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: isDark
                                  ? AppColors.pureBlack
                                  : AppColors.pureWhite,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // Duration badge
            if (isVideoSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.8)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '60s max',
                    style: TextStyle(
                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
