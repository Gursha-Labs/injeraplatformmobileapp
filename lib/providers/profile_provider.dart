import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:injera/api/api_service.dart';
import 'package:injera/models/user_profile.dart';

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ApiService _apiService;

  ProfileNotifier(this._apiService)
    : super(const ProfileState(isLoading: true)) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _apiService.getUserProfile();
      print("hhhhhhhhhhhhhhhhhhhhhhhh");
      print(profile.profilePicture);

      state = state.copyWith(profile: profile, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: ${e.toString()}',
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final updatedProfile = await _apiService.updateUserProfile(data);
      state = state.copyWith(
        profile: updatedProfile,
        isUpdating: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update profile: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> updateProfilePicture(File imageFile) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final updatedProfile = await _apiService.uploadProfilePicture(imageFile);
      state = state.copyWith(
        profile: updatedProfile,
        isUpdating: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update profile picture: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> deleteProfilePicture() async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final success = await _apiService.deleteProfilePicture();
      if (success && state.profile != null) {
        final updatedProfile = state.profile!.copyWith(profilePicture: null);
        state = state.copyWith(
          profile: updatedProfile,
          isUpdating: false,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to delete profile picture: ${e.toString()}',
      );
      rethrow;
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final service = ApiService();
  service.init();
  return service;
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final apiService = ref.watch(apiServiceProvider);
  return ProfileNotifier(apiService);
});
