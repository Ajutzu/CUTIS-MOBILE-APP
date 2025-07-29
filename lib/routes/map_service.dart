import 'api.dart';
import 'package:dio/dio.dart';

/// Model representing a dermatology clinic result returned by the server.
class ClinicMap {
  final String name;
  final String address;
  final double lat;
  final double lon;

  ClinicMap({
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
  });

  factory ClinicMap.fromJson(Map<String, dynamic> json) {
    return ClinicMap(
      name: json['name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}

/// Service class responsible for querying the backend search endpoint.
class MapService {
    /// Searches for dermatologist clinics near the supplied [location] string.
  /// The server should expose POST /api/maps/search which accepts JSON body
  /// { "location": "<lat,lon or query>", "query": "dermatologist" }
  /// and returns an array of clinic JSON objects similar to [ClinicMap].
  static Future<List<ClinicMap>> searchClinics(String location,
      {String query = 'dermatologist'}) async {
        final dio = Api().dio;
    final Response res = await dio.post(
      '/api/maps/search',
      data: {'location': location, 'query': query},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (res.statusCode != 200) {
      final msg = res.data is Map ? res.data['message'] : 'Failed to search clinics';
      throw Exception(msg);
    }

    final List<dynamic> data = res.data['data'];
    return data.map((e) => ClinicMap.fromJson(e as Map<String, dynamic>)).toList();
  }
}
