import 'package:permission_handler/permission_handler.dart';

class LocationPermissionService {
  static Future<bool> requestPermissions() async {
    var location = await Permission.location.request();
    var background = await Permission.locationAlways.request();
    var notification = await Permission.notification.request();

    return location.isGranted && background.isGranted;
  }
}
