import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notificaciones_service.dart';

class HistorialNotificaciones extends StatefulWidget {
  const HistorialNotificaciones({super.key});

  @override
  State<HistorialNotificaciones> createState() =>
      _HistorialNotificacionesState();
}

class _HistorialNotificacionesState extends State<HistorialNotificaciones> {
  final NotificacionesService _service = NotificacionesService();
  late PageController _pageController;

  bool mostrarDetalle = false;
  Map<String, dynamic>? notificacionActiva;

  bool isLoading = true;

  /// Listas
  List<Map<String, dynamic>> listaCompleta = [];
  List<Map<String, dynamic>> listaFiltrada = [];

  /// Filtros
  int mesSeleccionado = DateTime.now().month - 1;
  int? diaSemanaSeleccionado; // 1 (L) → 7 (D)

  final List<String> meses = [
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre",
  ];

  final List<Map<String, dynamic>> diasSemana = [
    {"label": "L", "value": 1},
    {"label": "M", "value": 2},
    {"label": "Mi", "value": 3},
    {"label": "J", "value": 4},
    {"label": "V", "value": 5},
    {"label": "S", "value": 6},
    {"label": "D", "value": 7},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1000 * meses.length + mesSeleccionado,
      viewportFraction: 0.4,
    );
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final data = await _service.getNotificaciones(token);

      setState(() {
        listaCompleta = data;
        _aplicarFiltros();
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _aplicarFiltros() {
    listaFiltrada =
        listaCompleta.where((notif) {
          final fecha = _parseFecha(notif['fecha']);
          if (fecha == null) return false;

          final coincideMes = fecha.month - 1 == mesSeleccionado;
          final coincideDia =
              diaSemanaSeleccionado == null ||
              fecha.weekday == diaSemanaSeleccionado;

          return coincideMes && coincideDia;
        }).toList();
  }

  DateTime? _parseFecha(dynamic fecha) {
    if (fecha is Map && fecha.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(fecha['_seconds'] * 1000);
    }
    return null;
  }

  String _formatearFecha(dynamic fecha) {
    final date = _parseFecha(fecha);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void mostrarBottomSheet(Map<String, dynamic> notif) {
    setState(() {
      mostrarDetalle = true;
      notificacionActiva = notif;
    });
  }

  void cerrarBottomSheet() {
    setState(() {
      mostrarDetalle = false;
      notificacionActiva = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: size.width * 0.5,
            child: Container(color: const Color(0xFF303030)),
          ),

          Column(
            children: [
              /// ================= HEADER =================
              Container(
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(size.width * 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Row(
                      children: [
                        const SizedBox(width: 30),
                        SvgPicture.asset(
                          'lib/assets/images/capas.svg',
                          height: size.width * 0.05,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Notificaciones",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),

                    /// MESES
                    SizedBox(
                      height: 100,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            mesSeleccionado = index % meses.length;
                            _aplicarFiltros();
                          });
                        },
                        itemBuilder: (context, index) {
                          final mesIndex = index % meses.length;
                          final page =
                              _pageController.page ??
                              _pageController.initialPage.toDouble();
                          final diff = (index - page).abs();
                          final central = diff < 0.5;

                          return Transform.scale(
                            scale: central ? 1.2 : 0.9,
                            child: Center(
                              child: Text(
                                meses[mesIndex],
                                style: TextStyle(
                                  fontSize: central ? 26 : 20,
                                  fontWeight:
                                      central
                                          ? FontWeight.bold
                                          : FontWeight.w400,
                                  color:
                                      central
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    /// DÍAS
                    SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            diasSemana.map((dia) {
                              final seleccionado =
                                  diaSemanaSeleccionado == dia['value'];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    diaSemanaSeleccionado =
                                        seleccionado ? null : dia['value'];
                                    _aplicarFiltros();
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient:
                                        seleccionado
                                            ? const LinearGradient(
                                              colors: [
                                                Color(0xFFE41335),
                                                Color(0xFF370B12),
                                              ],
                                            )
                                            : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      dia['label'],
                                      style: TextStyle(
                                        color:
                                            seleccionado
                                                ? Colors.white
                                                : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= LISTA =================
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF303030),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * 0.25),
                    ),
                  ),
                  child:
                      isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : listaFiltrada.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.notifications_off,
                                  color: Colors.white54,
                                  size: 60,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "No hay notificaciones",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 40,
                              bottom: 120,
                            ),
                            itemCount: listaFiltrada.length,
                            itemBuilder: (context, index) {
                              final notif = listaFiltrada[index];

                              return GestureDetector(
                                onTap: () => mostrarBottomSheet(notif),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3D3D3D),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          notif['imagen'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notif['titulo'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatearFecha(notif['fecha']),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),

          /// ================= MODAL =================
          if (mostrarDetalle && notificacionActiva != null) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: cerrarBottomSheet,
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
            ),
            Center(
              child: Container(
                width: size.width * 0.85,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      notificacionActiva!['imagen'],
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      notificacionActiva!['titulo'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE41335),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(_formatearFecha(notificacionActiva!['fecha'])),
                    const Divider(),
                    Text(notificacionActiva!['mensaje']),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: cerrarBottomSheet,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 90,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFE41335).withOpacity(0.8),
                              Color(0xFF370B12).withOpacity(0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(2, 4),
                              blurRadius: 8,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              offset: const Offset(-2, -2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            "Cerrar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
