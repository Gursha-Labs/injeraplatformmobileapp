// screens/advertiser/advertiser_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injera/api/config.dart';
import 'package:injera/models/advertiser_profile.dart';
import 'package:injera/providers/advertiser_profile_provider.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';
import 'package:injera/widgets/custom_text_field.dart';
import 'package:injera/widgets/loading_indicator.dart';

class AdvertiserProfileScreen extends ConsumerStatefulWidget {
  const AdvertiserProfileScreen({super.key});

  @override
  ConsumerState<AdvertiserProfileScreen> createState() =>
      _AdvertiserProfileScreenState();
}

class _AdvertiserProfileScreenState
    extends ConsumerState<AdvertiserProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  File? _profileImage;
  File? _coverImage;
  File? _logoImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    final profile = ref.read(advertiserProfileProvider).profile;
    if (profile != null) {
      _companyNameController.text = profile.companyName ?? '';
      _businessEmailController.text = profile.businessEmail ?? '';
      _phoneNumberController.text = profile.phoneNumber ?? '';
      _websiteController.text = profile.website ?? '';
      _descriptionController.text = profile.description ?? '';
      _countryController.text = profile.country ?? '';
      _cityController.text = profile.city ?? '';
      _addressController.text = profile.address ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _businessEmailController.dispose();
    _phoneNumberController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({
    required ImageSource source,
    bool isCover = false,
    bool isLogo = false,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (isCover) {
            _coverImage = File(pickedFile.path);
          } else if (isLogo) {
            _logoImage = File(pickedFile.path);
          } else {
            _profileImage = File(pickedFile.path);
          }
        });

        // If it's profile picture or logo, upload immediately
        if (!isCover) {
          await _uploadImage(isLogo: isLogo);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _uploadImage({bool isLogo = false}) async {
    try {
      setState(() => _isUploadingImage = true);

      await ref
          .read(advertiserProfileProvider.notifier)
          .updateProfile(
            profilePicture: isLogo ? null : _profileImage,
            logo: isLogo ? _logoImage : null,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${isLogo ? 'Logo' : 'Profile picture'} updated successfully',
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _uploadCoverImage() async {
    if (_coverImage == null) return;

    try {
      setState(() => _isUploadingImage = true);

      await ref
          .read(advertiserProfileProvider.notifier)
          .updateProfile(coverImage: _coverImage);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cover image updated successfully'),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading cover image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isUploading = true);
      await ref
          .read(advertiserProfileProvider.notifier)
          .updateProfile(
            companyName: _companyNameController.text,
            businessEmail: _businessEmailController.text,
            phoneNumber: _phoneNumberController.text,
            website: _websiteController.text,
            description: _descriptionController.text,
            country: _countryController.text,
            city: _cityController.text,
            address: _addressController.text,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildStatsRow(AdvertiserProfile profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            isDark: isDark,
            icon: Icons.video_library_outlined,
            value: profile.totalAdsUploaded.toString(),
            label: 'Ads',
          ),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            isDark: isDark,
            icon: Icons.visibility_outlined,
            value: profile.totalAdViews.toString(),
            label: 'Views',
          ),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            isDark: isDark,
            icon: Icons.attach_money_outlined,
            value: '\$${profile.totalSpent}',
            label: 'Spent',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required bool isDark,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  Widget _buildProfileHeader(AdvertiserProfile profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Cover Image
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  image: _coverImage != null
                      ? DecorationImage(
                          image: FileImage(_coverImage!),
                          fit: BoxFit.cover,
                        )
                      : (profile.coverImage != null
                            ? DecorationImage(
                                image: NetworkImage(
                                  ApiConfig.getStorageUrl(profile.coverImage!),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: _isUploadingImage && _coverImage != null
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const LoadingIndicator(size: 20),
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isUploadingImage
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: LoadingIndicator(size: 16),
                        )
                      : IconButton(
                          onPressed: () async {
                            final source = await _showImageSourceDialog();
                            if (source != null) {
                              await _pickImage(source: source, isCover: true);
                              if (_coverImage != null) {
                                await _uploadCoverImage();
                              }
                            }
                          },
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profile Picture
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (profile.profilePicture != null
                            ? NetworkImage(
                                ApiConfig.getStorageUrl(
                                  profile.profilePicture!,
                                ),
                              )
                            : null),
                  child: profile.profilePicture == null && _profileImage == null
                      ? Icon(
                          Icons.person_outline,
                          size: 50,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 10,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isUploadingImage
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: LoadingIndicator(size: 16),
                        )
                      : IconButton(
                          onPressed: () async {
                            final source = await _showImageSourceDialog();
                            if (source != null) {
                              await _pickImage(source: source);
                            }
                          },
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),

          // Company Name
          Text(
            profile.companyName ?? profile.username,
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            profile.businessEmail ?? profile.email,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required bool isDark,
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(AdvertiserProfile profile, bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Stats Section
          _buildStatsRow(profile, isDark),

          // Description Section
          if (profile.description != null && profile.description!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.pureWhite
                            : AppColors.pureBlack,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About Company',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.pureWhite
                              : AppColors.pureBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

          // Contact Information
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
                const SizedBox(height: 16),

                if (profile.phoneNumber != null &&
                    profile.phoneNumber!.isNotEmpty)
                  _buildInfoRow(
                    isDark: isDark,
                    icon: Icons.phone_outlined,
                    text: profile.phoneNumber!,
                  ),

                if (profile.website != null && profile.website!.isNotEmpty)
                  _buildInfoRow(
                    isDark: isDark,
                    icon: Icons.language_outlined,
                    text: profile.website!,
                  ),

                if (profile.businessEmail != null &&
                    profile.businessEmail!.isNotEmpty)
                  _buildInfoRow(
                    isDark: isDark,
                    icon: Icons.email_outlined,
                    text: profile.businessEmail!,
                  ),
              ],
            ),
          ),

          // Location Information
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
                const SizedBox(height: 16),

                if (profile.country != null && profile.country!.isNotEmpty)
                  _buildInfoRow(
                    isDark: isDark,
                    icon: Icons.location_on_outlined,
                    text: profile.country!,
                  ),

                if (profile.city != null && profile.city!.isNotEmpty)
                  _buildInfoRow(
                    isDark: isDark,
                    icon: Icons.location_city_outlined,
                    text: profile.city!,
                  ),

                if (profile.address != null && profile.address!.isNotEmpty)
                  _buildInfoRow(
                    isDark: isDark,
                    icon: Icons.home_outlined,
                    text: profile.address!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTab(AdvertiserProfile profile, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Logo Section
            Card(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Company Logo',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.pureWhite
                            : AppColors.pureBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDark ? Colors.grey[800] : Colors.grey[100],
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: _logoImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _logoImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : profile.logo != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    ApiConfig.getStorageUrl(profile.logo!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.business_outlined,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        size: 40,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.business_outlined,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  size: 40,
                                ),
                        ),
                        if (_isUploadingImage)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: const Center(
                                child: LoadingIndicator(size: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final source = await _showImageSourceDialog();
                          if (source != null) {
                            await _pickImage(source: source, isLogo: true);
                          }
                        },
                        icon: Icon(
                          Icons.upload_outlined,
                          size: 16,
                          color: isDark
                              ? AppColors.pureWhite
                              : AppColors.pureBlack,
                        ),
                        label: Text(
                          'Upload Logo',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.pureWhite
                                : AppColors.pureBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[400]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form Fields
            Card(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company Details',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.pureWhite
                            : AppColors.pureBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _companyNameController,
                      label: 'Company Name',
                      icon: Icons.business_outlined,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _businessEmailController,
                      label: 'Business Email',
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _phoneNumberController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _websiteController,
                      label: 'Website',
                      icon: Icons.language_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description_outlined,
                      isDark: isDark,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _countryController,
                            label: 'Country',
                            icon: Icons.flag_outlined,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _cityController,
                            label: 'City',
                            icon: Icons.location_city_outlined,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.home_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.pureWhite
                              : AppColors.pureBlack,
                          foregroundColor: isDark
                              ? AppColors.pureBlack
                              : AppColors.pureWhite,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isUploading
                            ? const LoadingIndicator(size: 20)
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosTab(bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        final profileState = ref.watch(advertiserProfileProvider);

        return FutureBuilder<List<dynamic>>(
          future: ref.read(advertiserProfileProvider.notifier).getOwnVideos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingIndicator(size: 32),
                    const SizedBox(height: 16),
                    Text(
                      'Loading videos...',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading videos',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.pureWhite
                            : AppColors.pureBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final videos = snapshot.data ?? [];

            if (videos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 64,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No videos uploaded yet',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.pureWhite
                            : AppColors.pureBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start creating your first campaign',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Container(
                          height: 120,
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          child: video['thumbnail_url'] != null
                              ? Image.network(
                                  video['thumbnail_url']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.videocam_outlined,
                                      size: 40,
                                      color: isDark
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.videocam_outlined,
                                  size: 40,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video['title'] ?? 'Untitled',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.pureWhite
                                    : AppColors.pureBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${video['views'] ?? 0}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.thumb_up_outlined,
                                  size: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${video['likes'] ?? 0}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final profileState = ref.watch(advertiserProfileProvider);

    if (profileState.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingIndicator(size: 40),
              const SizedBox(height: 20),
              Text(
                'Loading Profile',
                style: TextStyle(
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (profileState.error != null || profileState.profile == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(height: 24),
                Text(
                  profileState.error ?? 'Profile not found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => ref
                        .read(advertiserProfileProvider.notifier)
                        .loadProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.pureWhite
                          : AppColors.pureBlack,
                      foregroundColor: isDark
                          ? AppColors.pureBlack
                          : AppColors.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = profileState.profile!;
    final displayName = profile.companyName ?? 'Advertiser';

    return Scaffold(
      backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
        elevation: 0,
        title: Text(
          displayName,
          style: TextStyle(
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              size: 22,
            ),
            onPressed: () {
              _showMenu(context, isDark);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          _buildProfileHeader(profile, isDark),

          // Tab Bar
          Container(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                final tabs = ['Personal Info', 'Edit Profile', 'Campaigns'];
                return GestureDetector(
                  onTap: () {
                    _tabController.animateTo(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _tabController.index == index
                              ? (isDark
                                    ? AppColors.pureWhite
                                    : AppColors.pureBlack)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: _tabController.index == index
                            ? (isDark
                                  ? AppColors.pureWhite
                                  : AppColors.pureBlack)
                            : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        fontSize: 14,
                        fontWeight: _tabController.index == index
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalInfoTab(profile, isDark),
                _buildEditTab(profile, isDark),
                _buildVideosTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                context,
                isDark,
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
              _buildMenuItem(
                context,
                isDark,
                icon: Icons.share_outlined,
                label: 'Share Profile',
                onTap: () {
                  Navigator.pop(context);
                  _shareProfile();
                },
              ),
              _buildMenuItem(
                context,
                isDark,
                icon: Icons.logout_outlined,
                label: 'Logout',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context, isDark);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : (isDark ? AppColors.pureWhite : AppColors.pureBlack),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive
              ? Colors.red
              : (isDark ? AppColors.pureWhite : AppColors.pureBlack),
        ),
      ),
      onTap: onTap,
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality coming soon'),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, bool isDark) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Implement logout logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
