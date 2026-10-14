import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check whether location service is enabled.
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        print('LOCATION: GPS is OFF');
        return null;
      }

      // Check current permission.
      LocationPermission permission =
          await Geolocator.checkPermission();

      print('LOCATION: Permission = $permission');

      // Request permission if needed.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        print(
          'LOCATION: Permission after request = $permission',
        );
      }

      // User denied permission.
      if (permission == LocationPermission.denied) {
        print('LOCATION: Permission denied');
        return null;
      }

      // User permanently denied permission.
      if (permission == LocationPermission.deniedForever) {
        print('LOCATION: Permission permanently denied');
        return null;
      }

      // Get current position.
      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      print(
        'LOCATION SUCCESS: '
        '${position.latitude}, ${position.longitude}',
      );

      return position;
    } catch (e, stackTrace) {
      print('LOCATION ERROR: $e');
      print(stackTrace);

      return null;
    }
  }
}