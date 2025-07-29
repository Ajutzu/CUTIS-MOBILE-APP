import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_styles.dart';
import '../widgets/custom_app_bar.dart';
import '../../routes/session_service.dart';
import 'login.dart';
import '../content/skin_detection_page.dart';
import '../content/history_page.dart';
import '../content/history_detail_page.dart';
import '../content/ask_ai_page.dart';
import '../content/search_derm_page.dart';
import '../content/profile_page.dart';
import '../../routes/user_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  
  const HomeScreen({
    super.key,
    this.userName = '',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  int _currentIndex = 0;

  Map<String, dynamic>? _selectedHistoryRecord;
  
  // Page controller for smoother transitions
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addObserver(this);
    _validateSession();
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Validate session when app resumes
    if (state == AppLifecycleState.resumed) {
      _validateSession();
    }
  }

  /// Validates user session and redirects to login if invalid
  Future<void> _validateSession() async {
    try {
      final session = await SessionService().getSession();
      
      if (!session.isAuthenticated && mounted) {
        _navigateToLogin();
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // Handle session validation error
      debugPrint('Session validation error: $e');
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  /// Navigates to login screen and clears navigation stack
  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
      (route) => false,
    );
  }

  /// Navigates to Ask AI page by pushing a new route
  void _onNavigateToAskAi(Map<String, dynamic>? record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AskAIPage(historyRecord: record),
      ),
    );
  }

  /// Shows history detail page
  void _showHistoryDetail(Map<String, dynamic> record) async {
    setState(() {
      _isLoading = true;
    });
    final fullRecord = await UserService().getMedicalHistoryById(record['recordId']);
    setState(() {
      _selectedHistoryRecord = fullRecord ?? record;
      _isLoading = false;
      _currentIndex = 1; // Ensure we are on the history tab
    });
    // Animate to History tab in case we weren't already there
    if (_pageController.hasClients) {
      _pageController.jumpToPage(1);
    }
  }

  /// Hides history detail page
  void _hideHistoryDetail() {
    setState(() {
      _selectedHistoryRecord = null;
      _currentIndex = 1; // Always return to history tab
    });
    // Ensure we navigate back to History tab visually (after rebuild)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(1);
      }
    });
  }

  /// Handles bottom navigation tab changes
  void _onTabChanged(int index) {
    if (index == _currentIndex && _selectedHistoryRecord == null) return;

    HapticFeedback.lightImpact();

    setState(() {
      _currentIndex = index;
      _selectedHistoryRecord = null; // Hide detail page when changing tabs

    });

    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _pageController.jumpToPage(index);
    }
  }

  /// Builds the current page content
  Widget _buildCurrentPage() {
    // Show history detail if selected
    if (_currentIndex == 1 && _selectedHistoryRecord != null) {
      return Stack(
        children: [
          HistoryDetailPage(
            record: _selectedHistoryRecord!,
            onNavigateToAskAi: _onNavigateToAskAi,
            onBack: _hideHistoryDetail,
            onFindSpecialists: () {
              // TODO: Implement find specialists logic
              setState(() {
                _selectedHistoryRecord = null; // Hide detail page
                _currentIndex = 2; // Navigate to SearchDermPage
              });
              if (_pageController.hasClients) {
                _pageController.jumpToPage(2);
              }
            },
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      );
    }

    // Return main pages
    final pages = [
      const SkinDetectionPage(),
      HistoryPage(
        onNavigateToAskAi: _onNavigateToAskAi,
        onShowDetail: _showHistoryDetail,
      ),
      const SearchDermPage(),
      const ProfilePage(),
    ];

    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      children: pages,
    );
  }

  /// Builds the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        iconSize: 24,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Detect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// Builds the loading screen
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(userName: widget.userName),
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}