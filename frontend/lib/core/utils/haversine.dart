import 'dart:math' as math;

/// Menghitung jarak permukaan bumi antara dua koordinat GPS dalam satuan meter
/// menggunakan rumus Haversine.
double haversine(double lat1, double lng1, double lat2, double lng2) {
  const double earthRadiusM = 6371000.0;
  final double dLat = _toRadians(lat2 - lat1);
  final double dLng = _toRadians(lng2 - lng1);

  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);

  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusM * c;
}

/// Mengecek apakah jarak berada dalam radius check-in yang diizinkan.
bool isWithinCheckinRadius({
  required double jarakM,
  required double radiusCheckinMeter,
}) {
  return jarakM <= radiusCheckinMeter;
}

double _toRadians(double degree) => degree * (math.pi / 180.0);
