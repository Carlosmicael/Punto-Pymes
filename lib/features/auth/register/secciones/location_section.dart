import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class LocationSection extends StatelessWidget {
  final double width;
  final double height;
  final GlobalKey<FormState> formKey3;
  final TextEditingController empresaController;
  final TextEditingController sucursalController;
  final LatLng mapCenter;
  final Set<Marker> markers;
  final bool isKeyboardVisible;
  final bool locationDenied;
  final Function(GoogleMapController) onMapCreated;
  final Function() onRetryLocation;
  final Map<String, dynamic>? preRegistroData;

  const LocationSection({
    super.key,
    required this.width,
    required this.height,
    required this.formKey3,
    required this.empresaController,
    required this.sucursalController,
    required this.mapCenter,
    required this.markers,
    required this.isKeyboardVisible,
    required this.locationDenied,
    required this.onMapCreated,
    required this.onRetryLocation,
    this.preRegistroData,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey3,
      child: ListView(
        padding: EdgeInsets.only(top: height * 0.03),
        children: [
          // Campos de empresa de solo lectura
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- EMPRESA ---
                Text(
                  '  Empresa: ${empresaController.text.isEmpty ? "No asignada" : empresaController.text}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.039,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                //const SizedBox(height: 4),
                /*Text(
                  'ID Empresa: ${preRegistroData?['empresaId'] ?? "No disponible"}',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: width * 0.032,
                    fontStyle: FontStyle.italic,
                  ),
                ),*/

                const SizedBox(height: 10), // Espacio entre bloques
                // --- SUCURSAL ---
                Text(
                  '  Sucursal: ${sucursalController.text.isEmpty ? "No asignada" : sucursalController.text}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.039,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                //const SizedBox(height: 4),
                /*Text(
                  'ID Sucursal: ${preRegistroData?['branchId'] ?? "No disponible"}',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: width * 0.032,
                    fontStyle: FontStyle.italic,
                  ),
                ),*/
              ],
            ),
          ),

          SizedBox(height: height * 0.03),

          // Mapa con marcador fijo
          Container(
            height: height * 0.38,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white54, width: 1.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                zoomGesturesEnabled: false, // Deshabilitado
                scrollGesturesEnabled: false, // Deshabilitado
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: mapCenter,
                  zoom: 14,
                ),
                onMapCreated: onMapCreated,
                markers: markers,
                myLocationEnabled: false,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<EagerGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
