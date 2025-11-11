import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/screens/auth/login_screen.dart';
import 'package:injera/screens/auth/otp_verification_screen.dart';
import 'package:injera/screens/auth/signup_screen.dart';
import 'package:injera/providers/auth_provider.dart';
import 'package:injera/screens/games_screen.dart';
import 'package:injera/screens/home_screen.dart';
import 'package:injera/screens/profile_screen.dart';
import 'package:injera/screens/search_screen.dart';
import 'theme.dart';

class InjeraApp extends ConsumerWidget {
  const InjeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Injera',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show loading screen while checking auth status
    if (authState.status == AuthStatus.loading) {
      return _buildLoadingScreen();
    }

    // Route based on auth state
    return _buildContentBasedOnAuthState(authState);
  }

  Widget _buildContentBasedOnAuthState(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.authenticated:
        return const MainScreen();
      case AuthStatus.verificationRequired:
        return const OtpVerificationScreen();
      case AuthStatus.unauthenticated:
      default:
        return const LoginScreen();
    }
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFE2C55)),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // Replace with your HomeScreen
    const GamesScreen(), // Replace with your GamesScreen
    const SearchScreen(), // Replace with your SearchScreen
    const ProfileScreen(), // Replace with your ProfileScreen
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Games',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
