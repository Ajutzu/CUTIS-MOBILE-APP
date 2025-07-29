import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'history_detail_page.dart';

import '../theme/app_styles.dart';
import '../widgets/clinic_map.dart' as cm;
import '../widgets/search_bar.dart' show LocationSearchBar;
import '../widgets/disclaimer_banner.dart';
import '../../routes/map_service.dart';

class SearchDermPage extends StatefulWidget {
  const SearchDermPage({Key? key}) : super(key: key);

  @override
  State<SearchDermPage> createState() => _SearchDermPageState();
}

class _SearchDermPageState extends State<SearchDermPage> {
  final TextEditingController _controller = TextEditingController();
  List<ClinicMap> _clinics = [];
  LatLng? _center;
  bool _loading = false;
  bool _showDisclaimer = true;
  Map<String, dynamic>? _diagnosisData;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadDiagnosisData();
  }

  Future<void> _loadDiagnosisData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/output.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonContent = content.split('// response.json\n').last;
        setState(() {
          _diagnosisData = jsonDecode(jsonContent);
        });
      }
    } catch (e) {
      debugPrint('Error loading diagnosis data: $e');
    }
  }

  Future<void> _initLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;

    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _center = LatLng(pos.latitude, pos.longitude));
      await _search('${pos.latitude},${pos.longitude}');
    } catch (_) {}
  }

  Future<void> _search(String location) async {
    setState(() => _loading = true);
    try {
      final results = await MapService.searchClinics(location);
      setState(() {
        _clinics = results;
        if (results.isNotEmpty) {
          _center = LatLng(results.first.lat, results.first.lon);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _center == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                cm.ClinicMapView(clinics: _clinics, center: _center!),
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: LocationSearchBar(
                    controller: _controller,
                    loading: _loading,
                    onSearch: () {
                      if (_controller.text.isNotEmpty) {
                        _search(_controller.text);
                      }
                    },
                  ),
                ),
                if (_showDisclaimer)
                  Positioned(
                    top: 120,
                    left: 16,
                    right: 16,
                    child: DisclaimerBanner(
                      onClose: () =>
                          setState(() => _showDisclaimer = false),
                    ),
                  )
              ],
            ),
      floatingActionButton: _diagnosisData != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryDetailPage(
                      record: _diagnosisData!,
                      onBack: () => Navigator.of(context).pop(),
                      onFindSpecialists: () {},
                      onNavigateToAskAi: (record) {},
                    ),
                  ),
                );
              },
              label: const Text('View Last Diagnosis'),
              icon: const Icon(Icons.plagiarism_outlined),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}