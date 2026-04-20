// lib/models/withdrawal.dart
class Withdrawal {
  final String id;
  final double amount;
  final String withdrawalMethod;
  final String accountNumber;
  final String accountName;
  final String status;
  final String? withdrawalReference;
  final String? currency;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? reviewNotes;
  final String? processorReference;

  Withdrawal({
    required this.id,
    required this.amount,
    required this.withdrawalMethod,
    required this.accountNumber,
    required this.accountName,
    required this.status,
    this.withdrawalReference,
    this.currency,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.reviewNotes,
    this.processorReference,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    // FIX: Handle amount that might be String or num
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Withdrawal(
      id: json['id']?.toString() ?? '',
      amount: parseAmount(json['amount']),
      withdrawalMethod:
          json['witdrawal_method'] ?? json['withdrawal_method'] ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      withdrawalReference: json['withdrawal_reference']?.toString(),
      currency: json['currency']?.toString(),
      metadata: json['metadata'] is Map ? json['metadata'] : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      reviewNotes: json['review_notes']?.toString(),
      processorReference: json['processor_reference']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'witdrawal_method': withdrawalMethod,
      'account_number': accountNumber,
      'account_name': accountName,
      'status': status,
      'withdrawal_reference': withdrawalReference,
      'currency': currency,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'review_notes': reviewNotes,
      'processor_reference': processorReference,
    };
  }

  // Helper for UI
  bool get isPending => status == 'pending';
  bool get isUnderReview => status == 'under_review';
  bool get isProcessing => status == 'processing';
  bool get isPaid => status == 'paid';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';
  bool get isRejected => status == 'rejected';
  bool get isApproved => status == 'approved';

  bool get isCancellable => isPending || isUnderReview;

  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'under_review':
        return 'Under Review';
      case 'processing':
        return 'Processing';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      case 'approved':
        return 'Approved';
      default:
        return status;
    }
  }
}
