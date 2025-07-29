import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../widgets/history_record_card.dart';
import '../../routes/user_service.dart'; // Import the UserService

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
  final List<Map<String, dynamic>> _allRecords = [];
  final List<String> _severities = ['All Severities', 'Low', 'Moderate', 'High', 'Severe'];
  String _selectedSeverity = 'All Severities';
  List<Map<String, dynamic>> _displayedRecords = [];
  int _loadedCount = 0;
  final int _loadBatch = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMedicalHistory();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading) {
        _loadMore();
      }
    });
  }

  Future<void> _fetchMedicalHistory() async {
    setState(() => _isLoading = true);
    try {
      print('Fetching medical history...');
      final records = await UserService().getMedicalHistory();
      print('Received ${records.length} records');
      
      if (records.isEmpty) {
        print('No records received from API');
      }
      
      setState(() {
        _allRecords.addAll(records.map((record) {
          print('Processing record: ${record['id']}');
          return {
            'image': record['upload_skin'],
            'diagnosis': record['condition_description'],
            'date': DateTime.parse(record['diagnosis_date']),
            'severity': record['severity'],
            'recordId': record['id'],
            'treatment_recommendation': record['treatment_recommendation'] ?? 'Consult a dermatologist for proper treatment',
            'specialist': record['specialist'] ?? {'name': 'Dermatologist', 'type': 'Specialist'},
            'clinics': record['clinics'] ?? []
          };
        }).toList());
        _displayedRecords = _allRecords;
        print('Total records now: ${_allRecords.length}');
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching medical history: $e');
      setState(() => _isLoading = false);
    }
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
    print('Building HistoryPage with ${_displayedRecords.length} records');
    if (_displayedRecords.isNotEmpty) {
      print('First record: ${_displayedRecords.first}');
    }
    
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
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Showing ${_displayedRecords.length} of ${_selectedSeverity == 'All Severities' ? _allRecords.length : _allRecords.where((r) => r['severity'] == _selectedSeverity).length} records',
            style: TextStyle(color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading && _displayedRecords.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _displayedRecords.isEmpty
                    ? const Center(child: Text('No records found'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _displayedRecords.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _displayedRecords.length) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
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
