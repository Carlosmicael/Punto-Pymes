import 'package:shared_preferences/shared_preferences.dart';

class BranchConfigService {
  
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  static Future<void> saveBranchConfig({
    required dynamic lat,
    required dynamic lng,
    required dynamic radius,
    required dynamic threshold,
    required dynamic uid,
    required dynamic companyId,
    required dynamic branchId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('branchLat', _toDouble(lat));
    await prefs.setDouble('branchLng', _toDouble(lng));
    await prefs.setDouble('branchRadius', _toDouble(radius));
    await prefs.setDouble('threshold', _toDouble(threshold));
    await prefs.setString('uid', uid);
    await prefs.setString('companyId', companyId);
    await prefs.setString('branchId', branchId);
    
    print("✅ Guardado: lat=$_toDouble(lat), lng=$_toDouble(lng), radius=$_toDouble(radius)");
  }

  static Future<double> getLat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('branchLat') ?? 0.0;
  }

  static Future<double> getLng() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('branchLng') ?? 0.0;
  }

  static Future<double> getRadius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('branchRadius') ?? 0.0;
  }

  static Future<double> getThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('threshold') ?? 0.0;
  }

  static Future<String> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? '';
  }

  static Future<String> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('companyId') ?? '';
  }

  static Future<String> getBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('branchId') ?? '';
  }
}