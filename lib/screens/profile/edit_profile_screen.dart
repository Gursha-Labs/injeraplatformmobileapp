import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injera/models/user_profile.dart';
import 'package:injera/providers/profile_provider.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  DateTime? _selectedDate;
  String? _selectedGender;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;

    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _countryController = TextEditingController(text: profile?.country ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
    _selectedDate = profile?.dateOfBirth;
    _selectedGender = profile?.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> data = {};

    if (_firstNameController.text.isNotEmpty) {
      data['first_name'] = _firstNameController.text;
    }
    if (_lastNameController.text.isNotEmpty) {
      data['last_name'] = _lastNameController.text;
    }
    if (_phoneController.text.isNotEmpty) {
      data['phone_number'] = _phoneController.text;
    }
    if (_selectedDate != null) {
      data['date_of_birth'] = _selectedDate!.toIso8601String();
    }
    if (_selectedGender != null && _selectedGender!.isNotEmpty) {
      data['gender'] = _selectedGender;
    }
    if (_bioController.text.isNotEmpty) {
      data['bio'] = _bioController.text;
    }
    if (_countryController.text.isNotEmpty) {
      data['country'] = _countryController.text;
    }
    if (_cityController.text.isNotEmpty) {
      data['city'] = _cityController.text;
    }
    if (_addressController.text.isNotEmpty) {
      data['address'] = _addressController.text;
    }

    try {
      // First update profile data
      if (data.isNotEmpty) {
        await ref.read(profileProvider.notifier).updateProfile(data);
      }

      // Then upload profile picture if selected
      if (_selectedImage != null) {
        await ref
            .read(profileProvider.notifier)
            .updateProfilePicture(_selectedImage!);
      }

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar(context, 'Profile updated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (profileState.isUpdating)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile Picture
              _buildProfilePictureSection(isDark, profile),
              const SizedBox(height: 40),

              // Personal Info
              _buildSectionTitle('Personal Information', isDark),
              const SizedBox(height: 20),
              _buildNameFields(isDark),
              const SizedBox(height: 16),
              _buildPhoneField(isDark),
              const SizedBox(height: 16),
              _buildDateField(context, isDark),
              const SizedBox(height: 16),
              _buildGenderField(isDark),

              const SizedBox(height: 32),

              // Location
              _buildSectionTitle('Location', isDark),
              const SizedBox(height: 20),
              _buildCountryCityFields(isDark),
              const SizedBox(height: 16),
              _buildAddressField(isDark),

              const SizedBox(height: 32),

              // Bio
              _buildSectionTitle('About', isDark),
              const SizedBox(height: 20),
              _buildBioField(isDark),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(bool isDark, UserProfile? profile) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: _selectedImage != null
                  ? CircleAvatar(
                      radius: 58,
                      backgroundImage: FileImage(_selectedImage!),
                    )
                  : (profile?.profilePicture != null &&
                            profile!.profilePicture!.isNotEmpty
                        ? CircleAvatar(
                            radius: 58,
                            backgroundImage: NetworkImage(
                              profile.profilePicture!,
                            ),
                          )
                        : CircleAvatar(
                            radius: 58,
                            backgroundColor: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight,
                            child: Text(
                              profile?.initials ?? 'U',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.pureWhite
                                    : AppColors.pureBlack,
                              ),
                            ),
                          )),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.pureBlack : AppColors.pureWhite,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                    color: isDark ? AppColors.pureBlack : AppColors.pureWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to change photo',
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ],
    );
  }

  Widget _buildNameFields(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: 'First Name',
              labelStyle: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: 'Last Name',
              labelStyle: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: TextStyle(
        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        fontSize: 15,
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildDateField(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : '',
          ),
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            labelStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          style: TextStyle(
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Select gender')),
        DropdownMenuItem(value: 'male', child: Text('Male')),
        DropdownMenuItem(value: 'female', child: Text('Female')),
        DropdownMenuItem(value: 'other', child: Text('Other')),
        DropdownMenuItem(
          value: 'prefer_not_to_say',
          child: Text('Prefer not to say'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      style: TextStyle(
        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        fontSize: 15,
      ),
    );
  }

  Widget _buildCountryCityFields(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _countryController,
            decoration: InputDecoration(
              labelText: 'Country',
              labelStyle: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'City',
              labelStyle: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(bool isDark) {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Address',
        labelStyle: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: TextStyle(
        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        fontSize: 15,
      ),
      maxLines: 2,
    );
  }

  Widget _buildBioField(bool isDark) {
    return TextFormField(
      controller: _bioController,
      decoration: InputDecoration(
        labelText: 'Tell us about yourself',
        labelStyle: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: TextStyle(
        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        fontSize: 15,
      ),
      maxLines: 4,
      maxLength: 500,
    );
  }
}
