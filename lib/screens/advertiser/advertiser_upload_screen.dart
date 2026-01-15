// screens/advertiser/advertiser_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/category_provider.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/providers/upload_provider.dart';
import 'package:injera/theme/app_colors.dart';
import 'package:injera/upload/components/upload_progress.dart';
import 'package:injera/upload/components/upload_stats.dart';
import 'package:injera/upload/components/upload_error.dart';
import 'package:injera/upload/components/upload_success.dart';
import 'package:injera/upload/upload_utils.dart';
import 'package:video_player/video_player.dart';

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
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCategoryId;
  bool _showProductDetails = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).fetchCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _initVideoController() {
    final uploadState = ref.read(uploadProvider);
    if (uploadState.selectedVideo != null && _videoController == null) {
      _videoController = VideoPlayerController.file(uploadState.selectedVideo!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  void _clearVideo() {
    _videoController?.dispose();
    _videoController = null;
    ref.read(uploadProvider.notifier).clearVideo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final uploadState = ref.watch(uploadProvider);
    final categoryState = ref.watch(categoryProvider);

    // Initialize video controller when video is selected
    if (uploadState.selectedVideo != null && _videoController == null) {
      _initVideoController();
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: uploadState.uploadedAd != null
          ? UploadSuccess(
              ad: uploadState.uploadedAd!,
              isDark: isDark,
              onNewAd: _resetAll,
              onDashboard: () => Navigator.pop(context),
            )
          : Column(
              children: [
                // Custom App Bar
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (uploadState.isLoading)
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildContent(uploadState, categoryState, isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildContent(
    UploadState uploadState,
    CategoryState categoryState,
    bool isDark,
  ) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 56,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Section
                _buildVideoSection(uploadState, isDark),
                const SizedBox(height: 20),

                // Responsive Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 700) {
                      return _buildDesktopLayout(
                        uploadState,
                        categoryState,
                        isDark,
                      );
                    } else {
                      return _buildMobileLayout(
                        uploadState,
                        categoryState,
                        isDark,
                      );
                    }
                  },
                ),

                // Upload Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildUploadButton(uploadState, isDark),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        if (uploadState.error != null && !uploadState.isLoading)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: UploadError(
              error: uploadState.error!,
              isDark: isDark,
              onClear: () => ref.read(uploadProvider.notifier).clearError(),
            ),
          ),
        if (uploadState.isLoading)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: UploadProgress(state: uploadState, isDark: isDark),
          ),
      ],
    );
  }

  Widget _buildVideoSection(UploadState uploadState, bool isDark) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
        minHeight: 200,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[50],
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: uploadState.selectedVideo == null
            ? _buildVideoUploadPlaceholder(isDark)
            : _buildVideoPlayer(uploadState, isDark),
      ),
    );
  }

  Widget _buildVideoUploadPlaceholder(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white : Colors.black,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.videocam,
                size: 32,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload Video Ad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'MP4 format • Max 100MB',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.read(uploadProvider.notifier).pickVideo(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text('Select Video'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(UploadState uploadState, bool isDark) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_videoController != null && _videoController!.value.isInitialized)
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          )
        else
          Center(
            child: CircularProgressIndicator(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: _clearVideo,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
        if (_videoController != null && _videoController!.value.isInitialized)
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        // Add a "Select Another Video" button
        Positioned(
          bottom: 16,
          left: 16,
          child: ElevatedButton(
            onPressed: () => ref.read(uploadProvider.notifier).pickVideo(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            child: const Text('Change Video'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    UploadState uploadState,
    CategoryState categoryState,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Basic Info & Tags
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildBasicInfoCard(categoryState, isDark),
                const SizedBox(height: 16),
                _buildTagsCard(isDark),
                const SizedBox(height: 16),
                if (!uploadState.isLoading && uploadState.selectedVideo != null)
                  UploadStats(isDark: isDark),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column: Product Details & Stats
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildProductToggleCard(isDark),
                const SizedBox(height: 16),
                if (_showProductDetails) _buildProductDetailsCard(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    UploadState uploadState,
    CategoryState categoryState,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          _buildBasicInfoCard(categoryState, isDark),
          const SizedBox(height: 16),
          _buildTagsCard(isDark),
          const SizedBox(height: 16),
          _buildProductToggleCard(isDark),
          const SizedBox(height: 16),
          if (_showProductDetails) _buildProductDetailsCard(isDark),
          const SizedBox(height: 16),
          if (!uploadState.isLoading && uploadState.selectedVideo != null)
            UploadStats(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(CategoryState categoryState, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: isDark ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Two-column layout for title and category on desktop
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 400) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildCompactTextField(
                              controller: _titleController,
                              label: 'Title',
                              hint: 'Enter ad title',
                              icon: Icons.title,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildCompactTextField(
                              controller: _descriptionController,
                              label: 'Description',
                              hint: 'Describe your product or service',
                              icon: Icons.description,
                              isDark: isDark,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryDropdown(categoryState, isDark),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildCompactTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'Enter ad title',
                        icon: Icons.title,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(categoryState, isDark),
                      const SizedBox(height: 16),
                      _buildCompactTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe your product or service',
                        icon: Icons.description,
                        isDark: isDark,
                        maxLines: 3,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsCard(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tag,
                  size: 20,
                  color: isDark ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCompactTextField(
              controller: _tagsController,
              label: 'Add Tags',
              hint: 'food, restaurant, ethiopian (comma separated)',
              icon: Icons.local_offer,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductToggleCard(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.shopping_bag,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sell Products',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add price, location, and product images',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _showProductDetails,
              activeColor: Colors.black,
              onChanged: (value) {
                setState(() {
                  _showProductDetails = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsCard(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Price and Location side by side
            Row(
              children: [
                Expanded(
                  child: _buildCompactTextField(
                    controller: _priceController,
                    label: 'Price',
                    hint: '\$0.00',
                    icon: Icons.attach_money,
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCompactTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'City, State',
                    icon: Icons.location_on,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Product Images',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add up to 6 images of your product',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            _buildProductImagesPlaceholder(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  icon,
                  size: 18,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(CategoryState categoryState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              isExpanded: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.category,
                    size: 18,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ),
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select category'),
                ),
                ...categoryState.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImagesPlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Add Product Images',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag & drop or click to upload',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Image picker functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Upload Images'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(UploadState state, bool isDark) {
    final canUpload =
        state.selectedVideo != null &&
        _titleController.text.trim().isNotEmpty &&
        _selectedCategoryId != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canUpload && !state.isLoading ? _handleUpload : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canUpload ? Colors.black : Colors.grey[300],
          foregroundColor: canUpload ? Colors.white : Colors.grey[600],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: state.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                'Publish Ad',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _handleUpload() async {
    final token = await UploadUtils.getAuthToken();
    if (token == null) {
      _showSnackbar('Please log in to upload ads');
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
      _priceController.clear();
      _locationController.clear();
      _selectedCategoryId = null;
      _showProductDetails = false;
      _videoController?.dispose();
      _videoController = null;
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}
