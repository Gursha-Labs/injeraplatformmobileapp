import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slot_machine_ui/slot_machine_ui.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

// ==================== SLOT GAME APP ====================
class SlotGameApp extends ConsumerWidget {
  const SlotGameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "INJERA SLOTS",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        cardColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        dialogBackgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        primaryColor: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        hintColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        dividerColor: isDark ? AppColors.borderDark : AppColors.borderLight,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          bodyMedium: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          titleLarge: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
      home: const SlotGameScreen(),
    );
  }
}

// ==================== SLOT GAME SCREEN ====================
class SlotGameScreen extends ConsumerStatefulWidget {
  const SlotGameScreen({super.key});

  @override
  ConsumerState<SlotGameScreen> createState() => _SlotGameScreenState();
}

class _SlotGameScreenState extends ConsumerState<SlotGameScreen> {
  final SlotMachineController _controller = SlotMachineController();

  bool spinning = false;
  int userPoints = 1000;
  int betAmount = 10;
  int? lastWin;
  String? lastMessage;

  final List<String> symbols = ['🍒', '🍋', '7️⃣', '💎', '⭐', '🔔'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> spin() async {
    if (spinning) return;
    if (userPoints < betAmount) {
      _showInsufficientPointsDialog();
      return;
    }

    setState(() {
      spinning = true;
      lastWin = null;
      lastMessage = null;
      userPoints -= betAmount;
    });

    try {
      final response = await _callYourBackend(betAmount);

      setState(() {
        lastWin = response.winAmount;
        lastMessage = response.message;
        userPoints = response.newBalance;
      });

      _controller.spin();
    } catch (e) {
      setState(() {
        userPoints += betAmount;
        spinning = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  Future<BackendResponse> _callYourBackend(int bet) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();
    List<int> indexes = [
      random.nextInt(symbols.length),
      random.nextInt(symbols.length),
      random.nextInt(symbols.length),
    ];

    int winAmount = 0;
    if (indexes[0] == indexes[1] && indexes[1] == indexes[2]) {
      switch (indexes[0]) {
        case 2:
          winAmount = bet * 100;
          break;
        case 3:
          winAmount = bet * 50;
          break;
        case 4:
          winAmount = bet * 20;
          break;
        case 5:
          winAmount = bet * 10;
          break;
        default:
          winAmount = bet * 5;
      }
    }

    return BackendResponse(
      success: true,
      resultIndexes: indexes,
      winAmount: winAmount,
      newBalance: userPoints + winAmount,
      message: winAmount > 0 ? 'YOU WON $winAmount POINTS!' : 'Try again!',
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void onSpinResult(List<int> resultIndexes) {
    setState(() => spinning = false);

    if (lastWin != null && lastWin! > 0) {
      _showWinDialog();
    } else if (lastMessage != null) {
      _showTryAgainDialog();
    }
  }

  void _showWinDialog() {
    final isDark = ref.read(themeProvider).isDarkMode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            Text(
              'CONGRATULATIONS!',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark.withOpacity(0.5)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '+${lastWin!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'POINTS',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.success,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can redeem these points for rewards!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: const Text('CLAIM REWARDS'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            child: const Text('PLAY AGAIN'),
          ),
        ],
      ),
    );
  }

  void _showTryAgainDialog() {
    final isDark = ref.read(themeProvider).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: Text(
          'Better Luck Next Time!',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          lastMessage ?? 'Try again to win big!',
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInsufficientPointsDialog() {
    final isDark = ref.read(themeProvider).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: Text(
          'Insufficient Points',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Watch more videos to earn points and play again!',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            child: const Text('WATCH VIDEOS'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    final isDark = ref.read(themeProvider).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: Text(
          'Connection Error',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Failed to connect: $error',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'INJERA SLOTS',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            letterSpacing: 4,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        elevation: 0,
        foregroundColor: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
        // Removed the theme toggle button from actions
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Stats Bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    icon: Icons.account_balance_wallet,
                    label: 'MY POINTS',
                    value: userPoints.toString(),
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    isDark: isDark,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  _buildStatItem(
                    icon: Icons.local_offer,
                    label: 'BET',
                    value: betAmount.toString(),
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    isDark: isDark,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  _buildStatItem(
                    icon: Icons.emoji_events,
                    label: 'LAST WIN',
                    value: lastWin?.toString() ?? '-',
                    color: lastWin != null && lastWin! > 0
                        ? AppColors.success
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // Slot Machine
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.5)
                                : Colors.grey.shade300,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SlotMachineWidget(
                        width: 280,
                        controller: _controller,
                        symbols: symbols,
                        primaryColor: isDark
                            ? AppColors.pureWhite
                            : AppColors.pureBlack,
                        accentColor: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        showInnerFrame: true,
                        onResult: (resultIndexes) {
                          onSpinResult(resultIndexes.cast<int>());
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bet Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBetButton(
                          icon: Icons.remove,
                          onPressed: betAmount > 10
                              ? () => setState(() => betAmount -= 10)
                              : null,
                          isDark: isDark,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            'BET $betAmount',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        _buildBetButton(
                          icon: Icons.add,
                          onPressed: betAmount < 100
                              ? () => setState(() => betAmount += 10)
                              : null,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Spin Button
                    Container(
                      width: 200,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: spinning
                            ? []
                            : [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.5)
                                      : Colors.grey.shade400,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: spinning ? null : spin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: spinning
                              ? (isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400)
                              : (isDark
                                    ? AppColors.pureWhite
                                    : AppColors.pureBlack),
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          disabledBackgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                          disabledForegroundColor: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (spinning)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            if (spinning) const SizedBox(width: 12),
                            Text(
                              spinning ? 'SPINNING' : 'SPIN',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Bet Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildQuickBetButton('10', 10, isDark),
                        const SizedBox(width: 8),
                        _buildQuickBetButton('25', 25, isDark),
                        const SizedBox(width: 8),
                        _buildQuickBetButton('50', 50, isDark),
                        const SizedBox(width: 8),
                        _buildQuickBetButton('100', 100, isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBetButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPressed == null
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        border: Border.all(
          color: onPressed == null
              ? (isDark ? Colors.grey.shade700 : Colors.grey.shade400)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: onPressed == null
            ? (isDark ? Colors.grey.shade600 : Colors.grey.shade400)
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildQuickBetButton(String label, int amount, bool isDark) {
    final isSelected = betAmount == amount;
    return GestureDetector(
      onTap: () => setState(() => betAmount = amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}

class BackendResponse {
  final bool success;
  final List<int> resultIndexes;
  final int winAmount;
  final int newBalance;
  final String message;
  final String transactionId;
  final int timestamp;

  BackendResponse({
    required this.success,
    required this.resultIndexes,
    required this.winAmount,
    required this.newBalance,
    required this.message,
    required this.transactionId,
    required this.timestamp,
  });

  factory BackendResponse.fromJson(Map<String, dynamic> json) {
    return BackendResponse(
      success: json['success'] as bool,
      resultIndexes: List<int>.from(json['resultIndexes']),
      winAmount: json['winAmount'] as int,
      newBalance: json['newBalance'] as int,
      message: json['message'] as String,
      transactionId: json['transactionId'] as String,
      timestamp: json['timestamp'] as int,
    );
  }
}
