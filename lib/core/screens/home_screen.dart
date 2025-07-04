import 'package:flutter/material.dart';
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

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({Key? key, this.userName = ''}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _validateSession();
  }

  Future<void> _validateSession() async {
    final session = await SessionService().getSession();
    if (!session.isAuthenticated && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
        (route) => false,
      );
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }
  int _currentIndex = 0;
  Map<String, dynamic>? _askAiHistoryContext;
  Map<String, dynamic>? _selectedHistoryRecord;

  void _onNavigateToAskAi(Map<String, dynamic>? record) {
    setState(() {
      _askAiHistoryContext = record;
      _selectedHistoryRecord = null; // Hide detail page if open
      _currentIndex = 2; // Index of Ask AI page
    });
  }

  void _showHistoryDetail(Map<String, dynamic> record) {
    setState(() {
      _selectedHistoryRecord = record;
    });
  }

  void _hideHistoryDetail() {
    setState(() {
      _selectedHistoryRecord = null;
    });
  }

  Widget _buildCurrentPage() {
    if (_currentIndex == 1 && _selectedHistoryRecord != null) {
      return HistoryDetailPage(
        record: _selectedHistoryRecord!,
        onNavigateToAskAi: (record) {
          _onNavigateToAskAi(record);
        },
        onBack: _hideHistoryDetail,
      );
    }

    final pages = [
      const SkinDetectionPage(),
      HistoryPage(onNavigateToAskAi: _onNavigateToAskAi, onShowDetail: _showHistoryDetail),
      AskAIPage(historyRecord: _askAiHistoryContext),
      const SearchDermPage(),
      const ProfilePage(),
    ];

    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(userName: widget.userName),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _selectedHistoryRecord = null; // Reset detail view when changing tabs
            if (index != 2) {
              _askAiHistoryContext = null; // Reset context when leaving Ask AI page
            }
          });
        },
        backgroundColor: AppColors.secondary,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.primary.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Detect'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Ask AI'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
