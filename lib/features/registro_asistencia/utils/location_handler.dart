import 'package:geolocator/geolocator.dart';

class LocationHandler {
  /// Solicita permisos y obtiene la posición actual.
  /// Lanza excepciones controladas con mensajes para el usuario.
  static Future<Position> obtenerPosicionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si el GPS está encendido
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'El GPS está desactivado. Por favor enciéndelo.';
    }

    // 2. Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permisos de ubicación denegados.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Los permisos de ubicación están denegados permanentemente.';
    }

    // 3. Obtener ubicación con alta precisión
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}