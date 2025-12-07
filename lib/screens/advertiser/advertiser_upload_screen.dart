// screens/advertiser/advertiser_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/category_provider.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/providers/upload_provider.dart';
import 'package:injera/theme/app_colors.dart';
import 'package:injera/upload/components/upload_form.dart';
import 'package:injera/upload/components/upload_progress.dart';
import 'package:injera/upload/components/upload_stats.dart';
import 'package:injera/upload/components/upload_error.dart';
import 'package:injera/upload/components/upload_success.dart';
import 'package:injera/upload/components/upload_button.dart';
import 'package:injera/upload/upload_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvertiserUploadScreen extends ConsumerStatefulWidget {
  const AdvertiserUploadScreen({super.key});

  @override
  ConsumerState<AdvertiserUploadScreen> createState() =>
      _AdvertiserUploadScreenState();
}

class _AdvertiserUploadScreenState
    extends ConsumerState<AdvertiserUploadScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final uploadState = ref.watch(uploadProvider);
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: _buildAppBar(uploadState, isDark),
      body: uploadState.uploadedAd != null
          ? UploadSuccess(
              ad: uploadState.uploadedAd!,
              isDark: isDark,
              onNewAd: _resetAll,
              onDashboard: () => Navigator.pop(context),
            )
          : _buildBody(uploadState, categoryState, isDark),
      bottomNavigationBar: _buildBottomBar(uploadState, isDark),
    );
  }

  AppBar _buildAppBar(UploadState state, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppColors.iconDark : AppColors.iconLight,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Upload Ad',
        style: TextStyle(
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        if (state.isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(
    UploadState uploadState,
    CategoryState categoryState,
    bool isDark,
  ) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              UploadForm(
                titleController: _titleController,
                descriptionController: _descriptionController,
                tagsController: _tagsController,
                selectedCategoryId: _selectedCategoryId,
                categoryState: categoryState,
                isDark: isDark,
                onCategoryChanged: (value) => setState(() {
                  _selectedCategoryId = value;
                }),
                uploadState: uploadState,
                onPickVideo: () =>
                    ref.read(uploadProvider.notifier).pickVideo(),
                onClearVideo: uploadState.selectedVideo != null
                    ? () => ref.read(uploadProvider.notifier).clearVideo()
                    : null,
              ),
              const SizedBox(height: 16),
              if (uploadState.isLoading)
                UploadProgress(state: uploadState, isDark: isDark),
              if (!uploadState.isLoading && uploadState.selectedVideo != null)
                UploadStats(isDark: isDark),
            ],
          ),
        ),
        if (uploadState.error != null && !uploadState.isLoading)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: UploadError(
              error: uploadState.error!,
              isDark: isDark,
              onClear: () => ref.read(uploadProvider.notifier).clearError(),
            ),
          ),
      ],
    );
  }

  Widget? _buildBottomBar(UploadState state, bool isDark) {
    final canUpload =
        state.selectedVideo != null &&
        _titleController.text.trim().isNotEmpty &&
        _selectedCategoryId != null &&
        !state.isLoading;

    return canUpload
        ? UploadButton(
            isDark: isDark,
            hasVideo: state.selectedVideo != null,
            hasTitle: _titleController.text.isNotEmpty,
            hasCategory: _selectedCategoryId != null,
            onUpload: _handleUpload,
          )
        : null;
  }

  Future<void> _handleUpload() async {
    final token = await UploadUtils.getAuthToken();
    if (token == null) {
      _showSnackbar('Please log in to upload ads', ref);
      return;
    }

    final tags = UploadUtils.parseTags(_tagsController.text);

    await ref
        .read(uploadProvider.notifier)
        .uploadAd(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategoryId!,
          authToken: token,
          tags: tags,
        );
  }

  void _resetAll() {
    ref.read(uploadProvider.notifier).reset();
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _tagsController.clear();
      _selectedCategoryId = null;
    });
  }

  void _showSnackbar(String message, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
