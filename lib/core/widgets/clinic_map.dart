import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../routes/map_service.dart';

class ClinicMapView extends StatelessWidget {
  final List<ClinicMap> clinics;
  final LatLng center;
  final double zoom;
  const ClinicMapView({
    super.key,
    required this.clinics,
    required this.center,
    this.zoom = 12,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.cutis.app',
        ),
        MarkerLayer(
          markers: clinics
              .map(
                (c) => Marker(
                  height: 55,
                  width: 55,
                  point: LatLng(c.lat, c.lon),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(c.address, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/pin.png',
                      width: 55,
                      height: 55,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
