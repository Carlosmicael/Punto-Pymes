import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:auth_company/routes/app_routes.dart';
import 'package:auth_company/features/sucursales/services/sucursal_service.dart';
import 'package:auth_company/features/user/services/user_service.dart';

// Imagen por defecto (desde internet como pediste)
const String defaultImage =
    "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80";

class SucursalPage extends StatefulWidget {
  const SucursalPage({super.key});

  @override
  State<SucursalPage> createState() => _SucursalPageState();
}

class _SucursalPageState extends State<SucursalPage> {
  GoogleMapController? _mapController;
  final SucursalService _sucursalService = SucursalService();

  // AHORA ES UNA LISTA DE MAPAS
  List<Map<String, dynamic>> _sucursales = [];

  List<Map<String, dynamic>> _sucursalesFiltradas = [];

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  LatLng _initialPosition = const LatLng(-0.2104, -78.4907); // Default
  bool _isLoading = true;

  String? _userBranchId;

  String? _selectedSucursalId;

  LatLng? _userLocation;

  Future<void> _loadUserBranchId() async {
    final userService = UserService();
    final profile = await userService.getProfileRegistroManual();

    if (profile != null) {
      setState(() {
        _userBranchId = profile['branchId'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _getCurrentLocation(); // 1️⃣ GPS primero
    await _loadUserBranchId(); // 2️⃣ cargar branchId del usuario
    await _loadSucursales(); // 3️⃣ luego backend sucursales
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _userLocation = _initialPosition;
      });

      // 🔥 MOVER CÁMARA CUANDO YA EXISTE EL MAPA
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (e) {
      debugPrint("Error GPS: $e");
    }
  }

  Future<void> _loadSucursales() async {
    try {
      final data = await _sucursalService.getSucursales();

      setState(() {
        _sucursales = data;
        _sucursalesFiltradas = data;
        _buildMapElements();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _buildMapElements() {
    _markers.clear();
    _circles.clear();

    for (var s in _sucursales) {
      // ACCESO A DATOS USANDO CORCHETES ['key']
      final double lat = (s['latitud'] as num).toDouble();
      final double lng = (s['longitud'] as num).toDouble();
      final String id = s['id'];

      _markers.add(
        Marker(
          markerId: MarkerId(id),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: s['nombre'], snippet: s['direccion']),
          icon:
              (id == _selectedSucursalId)
                  ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  )
                  : BitmapDescriptor.defaultMarker,
        ),
      );

      // Dibujar círculo si coincide con la sucursal del empleado
      if (_userBranchId != null && id == _userBranchId) {
        _circles.add(
          Circle(
            circleId: CircleId("circle_$id"),
            center: LatLng(lat, lng),
            radius: (s['rangoGeografico'] as num).toDouble(),
            fillColor: Colors.green.withOpacity(0.3),
            strokeColor: Colors.green,
            strokeWidth: 2,
          ),
        );
      }
    }
  }

  void _goToLocation(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        key: const PageStorageKey("Sucursal"),
        child: Column(
          children: [
            const SizedBox(height: 100),

            // TÍTULO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'lib/assets/images/Sucursal.svg',
                    width: screenWidth * 0.07,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Sucursal',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // *** MAPA ***
            SizedBox(
              width: size.width,
              height: 350,
              child:
                  (_isLoading)
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition,
                          zoom: 14,
                        ),
                        onMapCreated:
                            (controller) => _mapController = controller,
                        markers: _markers,
                        circles: _circles,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
            ),

            // *** BUSCADOR FLOTANTE ***
            Transform.translate(
              offset: const Offset(0, -425),
              child: Container(
                width: size.width,
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(64, 0, 0, 0),
                      blurRadius: 30,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Buscar sucursal...",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          final query = value.toLowerCase();

                          setState(() {
                            _sucursalesFiltradas =
                                _sucursales.where((sucursal) {
                                  final nombre =
                                      sucursal['nombre']
                                          .toString()
                                          .toLowerCase();
                                  final direccion =
                                      sucursal['direccion']
                                          .toString()
                                          .toLowerCase();
                                  return nombre.contains(query) ||
                                      direccion.contains(query);
                                }).toList();
                          });

                          if (query.isEmpty) {
                            // Volver a ubicación del usuario
                            setState(() {
                              _selectedSucursalId = null;
                            });

                            if (_userLocation != null) {
                              _goToLocation(
                                _userLocation!.latitude,
                                _userLocation!.longitude,
                              );
                            }
                            return;
                          }

                          // Si hay texto → ir a la sucursal
                          if (_sucursalesFiltradas.isNotEmpty) {
                            final s = _sucursalesFiltradas.first;
                            final lat = (s['latitud'] as num).toDouble();
                            final lng = (s['longitud'] as num).toDouble();

                            setState(() {
                              _selectedSucursalId = s['id'];
                            });

                            _goToLocation(lat, lng);
                          }
                        },
                      ),
                    ),
                    const Icon(Icons.search),
                  ],
                ),
              ),
            ),

            // *** LISTA DE TARJETAS ***
            Transform.translate(
              offset: const Offset(0, -65),
              child: Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(64, 0, 0, 0),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header degradado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF370B12), Color(0xFFE41335)],
                        ),
                      ),
                      child: Text(
                        "${_sucursales.length} Sucursales",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // GENERACIÓN DE LISTA
                    Column(
                      children:
                          _sucursalesFiltradas.map((item) {
                            return _buildCard(context, item, screenWidth);
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET CARD: Recibe Map<String, dynamic>
  Widget _buildCard(
    BuildContext context,
    Map<String, dynamic> item,
    double screenWidth,
  ) {
    // Lógica de imagen
    final String urlImagen =
        (item['avatar'] != null && item['avatar'].toString().isNotEmpty)
            ? item['avatar']
            : defaultImage;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nombre'], // Acceso por clave
                  style: TextStyle(
                    fontSize: screenWidth * 0.043,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dirección: ${item['direccion']}",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    // BOTÓN VER
                    ElevatedButton(
                      onPressed: () {
                        // Pasamos el MAPA entero como argumento
                        Navigator.pushNamed(
                          context,
                          AppRoutes.detalleSucursal,
                          arguments: item,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        "Ver",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // BOTÓN UBICAR (Nuevo)
                    InkWell(
                      onTap: () {
                        final lat = (item['latitud'] as num).toDouble();
                        final lng = (item['longitud'] as num).toDouble();

                        setState(() {
                          _selectedSucursalId = item['id'];
                        });

                        _goToLocation(lat, lng);
                      },

                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE41335),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.gps_fixed,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // IMAGEN
          Container(
            width: screenWidth * 0.25,
            height: screenWidth * 0.25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(urlImagen),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
