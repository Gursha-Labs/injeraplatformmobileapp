// lib/screens/withdrawal/withdrawal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injera/api/api_service.dart';
import 'package:injera/models/withdrawal.dart.dart';
import '../../services/withdrawal_service.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen>
    with SingleTickerProviderStateMixin {
  final WithdrawalService _withdrawalService = WithdrawalService();
  final ApiService _apiService = ApiService();

  late TabController _tabController;

  List<Withdrawal> _withdrawals = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _error;

  // Track if we're doing a refresh operation
  bool _isRefreshing = false;

  // Withdrawal form
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  String? _selectedMethod;
  double? _walletBalance;
  bool _isSubmitting = false;
  String? _submitError;

  // Map for withdrawal method logos
  final Map<String, String> _methodLogos = {
    'telebirr': 'assets/telebirr.png',
    'mpesa': 'assets/mpesa.png', // fallback, not in your list
    'cbe_wallet': 'assets/cbebirr.png',
    'cbe': 'assets/cbe.png',
    'awash_bank': 'assets/awashbank.png',
    'dashen_bank': 'assets/dashenbank.png',
    'boa': 'assets/abysiniabank.png',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWalletBalance();
    _loadWithdrawals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final balance = await _apiService.getWalletBalance();
      if (mounted) {
        setState(() {
          _walletBalance = balance;
        });
      }
    } catch (e) {
      debugPrint('Failed to load wallet balance: $e');
    }
  }

  Future<void> _loadWithdrawals({bool refresh = false}) async {
    // Don't load if already loading or refreshing
    if (_isLoading || _isLoadingMore || _isRefreshing) return;

    if (refresh) {
      setState(() {
        _isRefreshing = true;
        _currentPage = 1;
        _hasMore = true;
        _error = null;
      });
    } else if (_currentPage == 1) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final withdrawals = await _withdrawalService.getUserWithdrawals(
        page: _currentPage,
        perPage: 15,
      );

      if (mounted) {
        setState(() {
          if (refresh || _currentPage == 1) {
            _withdrawals = withdrawals;
          } else {
            _withdrawals.addAll(withdrawals);
          }
          _hasMore = withdrawals.length >= 15;
          _error = null;

          // Only increment page if we got data and it's not a refresh
          if (!refresh && withdrawals.isNotEmpty && withdrawals.length >= 15) {
            _currentPage++;
          } else if (refresh && withdrawals.isNotEmpty) {
            _currentPage = 2;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a withdrawal method')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    if (_walletBalance != null && amount > _walletBalance!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. Available: ${_formatCurrency(_walletBalance!)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final withdrawal = await _withdrawalService.createWithdrawal(
        amount: amount,
        withdrawalMethod: _selectedMethod!,
        accountNumber: _accountNumberController.text.trim(),
        accountName: _accountNameController.text.trim(),
        currency: 'ETB',
      );

      // Clear form
      _amountController.clear();
      _accountNumberController.clear();
      _accountNameController.clear();
      setState(() {
        _selectedMethod = null;
      });

      // Switch to history tab
      _tabController.animateTo(1);

      // Refresh wallet balance and history
      await _loadWalletBalance();
      await _loadWithdrawals(refresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Withdrawal request of ${_formatCurrency(amount)} submitted successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _submitError = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _cancelWithdrawal(Withdrawal withdrawal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Cancel Withdrawal',
          style: TextStyle(color: Colors.black),
        ),
        content: Text(
          'Are you sure you want to cancel withdrawal of ${_formatCurrency(withdrawal.amount)}?',
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading indicator on the specific card
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _withdrawalService.cancelWithdrawal(withdrawal.id);

      // Update the local list instead of full refresh
      setState(() {
        // Remove the cancelled withdrawal from the list
        _withdrawals.removeWhere((w) => w.id == withdrawal.id);
        _isRefreshing = false;
      });

      // Refresh wallet balance
      await _loadWalletBalance();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to cancel: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    return 'ETB ${amount.toStringAsFixed(2)}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'rejected':
        return Colors.red.shade700;
      case 'approved':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Withdrawals',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Request', icon: Icon(Icons.request_page)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRequestTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet balance card - elegant minimal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  _walletBalance != null
                      ? _formatCurrency(_walletBalance!)
                      : 'Loading...',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Withdrawal form - clean and modern
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Request Withdrawal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'ETB ',

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Invalid amount';
                      }
                      if (amount < 1) {
                        return 'Minimum withdrawal is ETB 1';
                      }
                      if (_walletBalance != null && amount > _walletBalance!) {
                        return 'Insufficient balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Withdrawal Method with horizontal image selection
                  const Text(
                    'Select Method',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: WithdrawalService.withdrawalMethods.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final method =
                            WithdrawalService.withdrawalMethods[index];
                        final isSelected = _selectedMethod == method;
                        final logoPath = _methodLogos[method];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMethod = method;
                            });
                          },
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.red.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.red
                                    : Colors.black.withOpacity(0.1),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (logoPath != null)
                                  Image.asset(
                                    logoPath,
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatMethodNameShort(method),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Colors.red
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Account Number
                  TextFormField(
                    controller: _accountNumberController,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter account number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Account Name
                  TextFormField(
                    controller: _accountNameController,
                    decoration: InputDecoration(
                      labelText: 'Account Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter account name';
                      }
                      return null;
                    },
                  ),

                  if (_submitError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _submitError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitWithdrawal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Submit Request',
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
        ],
      ),
    );
  }

  String _formatMethodNameShort(String method) {
    switch (method) {
      case 'telebirr':
        return 'Telebirr';
      case 'mpesa':
        return 'M-Pesa';
      case 'cbe_wallet':
        return 'CBE Birr';
      case 'cbe':
        return 'CBE';
      case 'awash_bank':
        return 'Awash';
      case 'dashen_bank':
        return 'Dashen';
      case 'boa':
        return 'Abyssinia';
      default:
        return method;
    }
  }

  String _formatMethodName(String method) {
    switch (method) {
      case 'telebirr':
        return 'Telebirr';
      case 'mpesa':
        return 'M-Pesa';
      case 'cbe_wallet':
        return 'CBE Birr';
      case 'cbe':
        return 'Commercial Bank of Ethiopia';
      case 'awash_bank':
        return 'Awash Bank';
      case 'dashen_bank':
        return 'Dashen Bank';
      case 'boa':
        return 'Bank of Abyssinia';
      default:
        return method;
    }
  }

  Widget _buildHistoryTab() {
    if ((_isLoading || _isRefreshing) && _withdrawals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _withdrawals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadWithdrawals(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_withdrawals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No withdrawal requests yet'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _tabController.animateTo(0),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Request a Withdrawal'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadWithdrawals(refresh: true),
      color: Colors.red,
      child: ListView.builder(
        itemCount: _withdrawals.length + (_hasMore && !_isRefreshing ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _withdrawals.length) {
            if (_isLoadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (_hasMore && !_isRefreshing) {
              // Load more items
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadWithdrawals();
              });
            }
            return const SizedBox.shrink();
          }

          final withdrawal = _withdrawals[index];
          return _buildWithdrawalCard(withdrawal);
        },
      ),
    );
  }

  Widget _buildWithdrawalCard(Withdrawal withdrawal) {
    final logoPath = _methodLogos[withdrawal.withdrawalMethod];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.black.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo container
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: logoPath != null
                      ? Image.asset(logoPath, fit: BoxFit.contain)
                      : const Icon(
                          Icons.account_balance,
                          color: Colors.black54,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatCurrency(withdrawal.amount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatMethodName(withdrawal.withdrawalMethod),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(withdrawal.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    withdrawal.displayStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(withdrawal.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Account: ${withdrawal.accountNumber}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(withdrawal.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Name: ${withdrawal.accountName}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
            if (withdrawal.withdrawalReference != null) ...[
              const SizedBox(height: 4),
              Text(
                'Ref: ${withdrawal.withdrawalReference}',
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
            if (withdrawal.reviewNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Note: ${withdrawal.reviewNotes}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
            if (withdrawal.isCancellable) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelWithdrawal(withdrawal),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel Request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
