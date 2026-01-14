// screens/test/profile_test_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/models/advertiser_profile.dart';
import 'package:injera/providers/advertiser_profile_provider.dart';
import 'package:injera/utils/debug_util.dart';

class ProfileTestScreen extends ConsumerWidget {
  const ProfileTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(advertiserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStateInfo(profileState),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                DebugUtil.logJson('MANUAL_RELOAD', {});
                ref.read(advertiserProfileProvider.notifier).loadProfile();
              },
              child: const Text('Reload Profile'),
            ),
            const SizedBox(height: 20),
            if (profileState.profile != null)
              _buildProfileDetails(profileState.profile!),
          ],
        ),
      ),
    );
  }

  Widget _buildStateInfo(AdvertiserProfileState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('State Info'),
            const SizedBox(height: 10),
            Text('isLoading: ${state.isLoading}'),
            Text('isUpdating: ${state.isUpdating}'),
            Text('hasError: ${state.error != null}'),
            Text('hasProfile: ${state.profile != null}'),
            if (state.error != null) ...[
              const SizedBox(height: 10),
              Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(AdvertiserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Details'),
            const SizedBox(height: 10),
            Text('User ID: ${profile.userId}'),
            Text('Username: ${profile.username}'),
            Text('Email: ${profile.email}'),
            Text('Company: ${profile.companyName ?? "N/A"}'),
            Text('Phone: ${profile.phoneNumber ?? "N/A"}'),
            Text('Country: ${profile.country ?? "N/A"}'),
            Text('City: ${profile.city ?? "N/A"}'),
            Text('Total Ads: ${profile.totalAdsUploaded}'),
            Text('Total Views: ${profile.totalAdViews}'),
            Text('Total Spent: \$${profile.totalSpent}'),
          ],
        ),
      ),
    );
  }
}
