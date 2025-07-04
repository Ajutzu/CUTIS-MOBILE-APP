import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class SearchDermPage extends StatefulWidget {
  const SearchDermPage({Key? key}) : super(key: key);

  @override
  _SearchDermPageState createState() => _SearchDermPageState();
}

class _SearchDermPageState extends State<SearchDermPage> {
  final List<Map<String, dynamic>> _clinics = [
    {'name': 'Serene Skin Clinic', 'top': 200.0, 'left': 80.0},
    {'name': 'Advanced Dermatology', 'top': 350.0, 'left': 60.0},
    {'name': 'The Skin Specialists', 'top': 450.0, 'left': 120.0},
    {'name': 'Radiant Dermatology', 'top': 180.0, 'left': 220.0},
    {'name': 'Clear Skin Center', 'top': 480.0, 'left': 280.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/Maps.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.lighten,
          ),
          _buildSearchBar(),
          ..._clinics.map((clinic) {
            return _buildMapPin(
              top: clinic['top'],
              left: clinic['left'],
              label: clinic['name'],
            );
          }).toList(),
          Positioned(
            top: 400,
            left: 180,
            child: Icon(Icons.my_location, color: AppColors.primary, size: 40),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Card(
        color: AppColors.secondary,
        surfaceTintColor: AppColors.secondary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search for derma clinics...',
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPin({required double top, required double left, required String label}) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: const Icon(Icons.local_hospital_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
