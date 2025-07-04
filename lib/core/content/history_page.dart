import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../widgets/history_record_card.dart';

class HistoryPage extends StatefulWidget {
  final Function(Map<String, dynamic>?) onNavigateToAskAi;
  final Function(Map<String, dynamic>) onShowDetail;

  const HistoryPage({
    Key? key,
    required this.onNavigateToAskAi,
    required this.onShowDetail,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _allRecords = List.generate(20, (index) {
    final severities = ['Low', 'Moderate', 'High', 'Severe'];
    final conditions = ['Acne', 'Warts', 'Eczema', 'Psoriasis'];
    return {
      'image': 'assets/images/Icon.png',
      'diagnosis': 'AI-detected skin condition: ${conditions[index % conditions.length]}',
      'date': DateTime(2025, 6, 23, 8, 53).add(Duration(days: index)),
      'severity': severities[index % severities.length],
      'recordId': '6858a5a5f5b50afd0083808$index',
      'treatment_recommendation': 'Follow up with a dermatologist. Over-the-counter salicylic acid treatments can be effective. Avoid picking at the affected area.',
      'specialist': {
        'name': 'Dr. Evelyn Reed',
        'type': 'Dermatologist',
      },
      'clinics': [
        {'name': 'Serene Skin Clinic', 'address': '123 Wellness Ave, Suite 101'},
        {'name': 'Advanced Dermatology Center', 'address': '456 Health St, Building B'},
      ]
    };
  });
  final List<String> _severities = ['All Severities', 'Low', 'Moderate', 'High', 'Severe'];
  String _selectedSeverity = 'All Severities';
  List<Map<String, dynamic>> _displayedRecords = [];
  int _loadedCount = 0;
  final int _loadBatch = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading) {
        _loadMore();
      }
    });
  }

  void _loadMore() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      List<Map<String, dynamic>> filtered = _selectedSeverity == 'All Severities'
          ? _allRecords
          : _allRecords.where((r) => r['severity'] == _selectedSeverity).toList();
      int nextCount = (_loadedCount + _loadBatch).clamp(0, filtered.length);
      setState(() {
        _displayedRecords = filtered.take(nextCount).toList();
        _loadedCount = nextCount;
        _isLoading = false;
      });
    });
  }

  void _onSeverityChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedSeverity = value;
      _loadedCount = 0;
      _displayedRecords = [];
    });
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Filter by severity:', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.text)),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedSeverity,
                items: _severities.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: _onSeverityChanged,
                dropdownColor: AppColors.secondary,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _loadedCount = 0;
                    _displayedRecords = [];
                  });
                  _loadMore();
                },
              ),
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
                onPressed: () {
                  widget.onNavigateToAskAi(null);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Showing ${_displayedRecords.length} of ${_selectedSeverity == 'All Severities' ? _allRecords.length : _allRecords.where((r) => r['severity'] == _selectedSeverity).length} records',
            style: TextStyle(color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _displayedRecords.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _displayedRecords.length) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  ));
                }
                final record = _displayedRecords[index];
                return HistoryRecordCard(
                  record: record,
                  onNavigateToAskAi: widget.onNavigateToAskAi,
                  onShowDetail: widget.onShowDetail,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

