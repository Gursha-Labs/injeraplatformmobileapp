// upload/components/upload_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/category_provider.dart';
import 'package:injera/providers/upload_provider.dart';
import 'package:injera/theme/app_colors.dart';
import 'package:injera/widgets/video_preview_widget.dart';

class UploadForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;
  final String? selectedCategoryId;
  final CategoryState categoryState;
  final bool isDark;
  final Function(String?) onCategoryChanged;
  final UploadState uploadState;
  final VoidCallback onPickVideo;
  final VoidCallback? onClearVideo;

  const UploadForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.tagsController,
    required this.selectedCategoryId,
    required this.categoryState,
    required this.isDark,
    required this.onCategoryChanged,
    required this.uploadState,
    required this.onPickVideo,
    this.onClearVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VideoPickerWidget(
          onPickVideo: onPickVideo,
          selectedVideo: uploadState.selectedVideo,
          videoName: uploadState.selectedVideoName,
          onClearVideo: onClearVideo,
        ),
        const SizedBox(height: 20),
        _buildCompactForm(),
      ],
    );
  }

  Widget _buildCompactForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: titleController,
                label: 'Title *',
                hintText: 'Ad title...',
                maxLength: 60,
              ),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: descriptionController,
                label: 'Description',
                hintText: 'Brief description...',
                maxLines: 2,
                maxLength: 140,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: tagsController,
                label: 'Tags',
                hintText: 'comma, separated, tags',
                helperText: 'Optional',
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? helperText,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (helperText != null) ...[
              const SizedBox(width: 4),
              Text(
                '($helperText)',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: maxLines == 1 ? 40 : 60,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              counterText: '',
            ),
            maxLines: maxLines,
            maxLength: maxLength,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategoryId,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        categoryState.isLoading
                            ? 'Loading...'
                            : 'Select category',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    isExpanded: true,
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: categoryState.isLoading
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            )
                          : Icon(
                              Icons.arrow_drop_down,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                    ),
                    items: categoryState.categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onCategoryChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
