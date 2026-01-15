// providers/advertiser_profile_provider.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:injera/models/advertiser_profile.dart';
import 'package:injera/services/advertiser_profile_service.dart';
import 'package:injera/utils/debug_util.dart';

final advertiserProfileProvider =
    StateNotifierProvider<AdvertiserProfileNotifier, AdvertiserProfileState>(
      (ref) => AdvertiserProfileNotifier(),
    );

class AdvertiserProfileState {
  final AdvertiserProfile? profile;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  AdvertiserProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  AdvertiserProfileState copyWith({
    AdvertiserProfile? profile,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return AdvertiserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class AdvertiserProfileNotifier extends StateNotifier<AdvertiserProfileState> {
  final AdvertiserProfileService _service = AdvertiserProfileService();

  AdvertiserProfileNotifier() : super(AdvertiserProfileState(isLoading: true)) {
    loadProfile();
  }

  // providers/advertiser_profile_provider.dart - Update loadProfile
  Future<void> loadProfile() async {
    DebugUtil.logJson('PROVIDER_LOAD_PROFILE_START', {});

    try {
      state = state.copyWith(isLoading: true, error: null);
      DebugUtil.logJson('PROVIDER_STATE_UPDATED', {'isLoading': true});

      final profile = await _service.getProfile();
      DebugUtil.logJson('PROVIDER_PROFILE_RECEIVED', {
        'userId': profile.userId,
        'username': profile.username,
        'type': profile.type,
      });

      state = state.copyWith(profile: profile, isLoading: false);
      DebugUtil.logJson('PROVIDER_STATE_UPDATED', {
        'isLoading': false,
        'hasProfile': profile != null,
      });
    } catch (e, stackTrace) {
      DebugUtil.logError('PROVIDER_LOAD_PROFILE_ERROR', e, stackTrace);
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        profile: null,
      );
    }
  }

  // Update in providers/advertiser_profile_provider.dart
  Future<void> updateProfile({
    String? companyName,
    String? businessEmail,
    String? phoneNumber,
    String? website,
    String? description,
    String? country,
    String? city,
    String? address,
    File? logo,
    File? profilePicture,
    File? coverImage,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      final updatedProfile = await _service.updateProfile(
        companyName: companyName,
        businessEmail: businessEmail,
        phoneNumber: phoneNumber,
        website: website,
        description: description,
        country: country,
        city: city,
        address: address,
        logo: logo,
        profilePicture: profilePicture,
        coverImage: coverImage,
      );
      state = state.copyWith(profile: updatedProfile, isUpdating: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isUpdating: false);
      rethrow;
    }
  }

  Future<void> updateProfilePicture() async {
    // Implementation for profile picture update
  }

  Future<void> deleteProfilePicture() async {
    try {
      await _service.deleteProfilePicture();
      final currentProfile = state.profile;
      if (currentProfile != null) {
        state = state.copyWith(
          profile: currentProfile.copyWith(profilePicture: null),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<List<dynamic>> getOwnVideos() async {
    return await _service.getOwnVideos();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
