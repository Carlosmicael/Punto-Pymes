import 'package:auth_company/features/tracking/location_tracking_service.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();
  await LocationTrackingService.initializeNotifications();


  runApp(const HomeApp());
}
