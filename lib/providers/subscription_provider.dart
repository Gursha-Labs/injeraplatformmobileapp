// lib/providers/subscription_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:injera/models/subscription_models.dart';
import 'package:injera/services/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

class SubscriptionState {
  final List<Subscription> subscriptions;
  final UserSubscription? currentSubscription;
  final bool isLoading;
  final String? error;

  SubscriptionState({
    required this.subscriptions,
    this.currentSubscription,
    required this.isLoading,
    this.error,
  });

  factory SubscriptionState.initial() {
    return SubscriptionState(
      subscriptions: [],
      currentSubscription: null,
      isLoading: false,
      error: null,
    );
  }

  SubscriptionState copyWith({
    List<Subscription>? subscriptions,
    UserSubscription? currentSubscription,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      subscriptions: subscriptions ?? this.subscriptions,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Subscription> get activeSubscriptions {
    return subscriptions.where((sub) => sub.isActive).toList();
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionService _subscriptionService;

  SubscriptionNotifier(this._subscriptionService)
    : super(SubscriptionState.initial());

  Future<void> fetchSubscriptions() async {
    state = state.copyWith(isLoading: true, error: null);
    debugPrint('Fetching subscriptions...');

    try {
      final response = await _subscriptionService.getSubscriptions();

      if (response.success && response.data.isNotEmpty) {
        state = state.copyWith(
          subscriptions: response.data,
          isLoading: false,
          error: null,
        );
        debugPrint('Loaded ${response.data.length} subscriptions');
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        debugPrint('Failed to load subscriptions: ${response.message}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('Error: $e');
    }
  }

  Future<void> fetchCurrentSubscription() async {
    debugPrint('Fetching current subscription...');

    try {
      final subscription = await _subscriptionService.getUserSubscription();
      state = state.copyWith(currentSubscription: subscription);
      debugPrint(
        'Current subscription: ${subscription?.subscription.name ?? 'None'}',
      );
    } catch (e) {
      debugPrint('Error fetching current subscription: $e');
      state = state.copyWith(currentSubscription: null);
    }
  }

  Future<bool> subscribeToPlan(String subscriptionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _subscriptionService.subscribeToPlan(subscriptionId);

      if (result != null && result.success) {
        await fetchCurrentSubscription();
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Subscription failed');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancelSubscription() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _subscriptionService.cancelSubscription();

      if (success) {
        await fetchCurrentSubscription();
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to cancel subscription',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      final service = ref.watch(subscriptionServiceProvider);
      return SubscriptionNotifier(service);
    });
