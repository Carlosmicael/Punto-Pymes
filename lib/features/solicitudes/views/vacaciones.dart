import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auth_company/routes/app_routes.dart';
import '../services/solicitudes_service.dart';
import 'package:intl/intl.dart';

class VacacionesScreen extends StatefulWidget {
  const VacacionesScreen({super.key});

  @override
  State<VacacionesScreen> createState() => _VacacionesScreenState();
}

class _VacacionesScreenState extends State<VacacionesScreen> {
  final SolicitudesService _service = SolicitudesService();

  List<Map<String, dynamic>> _todasSolicitudes = [];
  List<Map<String, dynamic>> _solicitudesFiltradas = [];

  // Filtros
  String _filtroTipo = "Todos";
  DateTime? _filtroFecha;
  String _busqueda = "";

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datos = await _service.getSolicitudes();
    setState(() {
      _todasSolicitudes = datos;
      _aplicarFiltros();
    });
  }

  void _aplicarFiltros() {
    _solicitudesFiltradas =
        _todasSolicitudes.where((s) {
          final matchTipo =
              _filtroTipo == "Todos" || s['tipoSolicitud'] == _filtroTipo;

          bool matchFecha = true;
          if (_filtroFecha != null && s['fechaCreacion'] != null) {
            final fecha = _parseFecha(s['fechaCreacion']);

            print("🗓 Fecha raw: ${s['fechaCreacion']}");
            print("🗓 Fecha parseada: $fecha");
            print("🗓 Filtro seleccionado: $_filtroFecha");

            if (fecha == null) {
              print("❌ Fecha inválida, se descarta solicitud");
              return false;
            }

            final fechaSolicitud = DateTime(fecha.year, fecha.month, fecha.day);

            final fechaFiltro = DateTime(
              _filtroFecha!.year,
              _filtroFecha!.month,
              _filtroFecha!.day,
            );

            matchFecha = fechaSolicitud == fechaFiltro;

            print("📅 Fecha solicitud normalizada: $fechaSolicitud");
            print("📅 Fecha filtro normalizada: $fechaFiltro");
            print("✅ Coinciden: $matchFecha");

            print(
              "📊 Comparación -> "
              "mes igual: ${fecha.month == _filtroFecha!.month}, "
              "año igual: ${fecha.year == _filtroFecha!.year}",
            );
          }

          final search = _busqueda.toLowerCase();
          final matchSearch =
              _busqueda.isEmpty ||
              (s['id']?.toString().toLowerCase().contains(search) ?? false) ||
              (s['motivo']?.toLowerCase().contains(search) ?? false);

          return matchTipo && matchFecha && matchSearch;
        }).toList();

    setState(() {});
  }

  DateTime? _parseFecha(dynamic fechaRaw) {
    print("🔍 Intentando parsear fecha: $fechaRaw");

    if (fechaRaw == null) return null;

    if (fechaRaw is Map) {
      final seconds = fechaRaw['_seconds'];
      if (seconds is int) {
        final parsed =
            DateTime.fromMillisecondsSinceEpoch(
              seconds * 1000,
              isUtc: true,
            ).toLocal();
        print("✅ Fecha Firebase parseada: $parsed");
        return parsed;
      }
    }

    if (fechaRaw is String) {
      final parsed = DateTime.tryParse(fechaRaw);
      print("✅ Fecha String parseada: $parsed");
      return parsed;
    }

    print("⚠️ Formato de fecha no reconocido");
    return null;
  }

  String _formatFecha(dynamic fechaRaw) {
    final fecha = _parseFecha(fechaRaw);
    if (fecha == null) return "--";

    return DateFormat('d MMM yyyy', 'es').format(fecha);
  }

  void _confirmarEliminar(String solicitudId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔴 HEADER CON GRADIENTE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7B1522), Color(0xFFE41335)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Eliminar solicitud",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔹 CONTENIDO
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Text(
                    "¿Estás seguro de eliminar esta solicitud?\n\n"
                    "⚠️ Esta acción no se puede revertir una vez eliminada la solicitud.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),

                const Divider(height: 1),

                /// 🔹 ACCIONES
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancelar"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE41335),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 4,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _service.deleteSolicitud(solicitudId);
                            await _cargarDatos(); // 🔄 refrescar lista
                          },
                          child: const Text(
                            "Eliminar",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),

            /// 🔹 HEADER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "lib/assets/images/Vacaciones.svg",
                    width: width * 0.06,
                    height: width * 0.06,
                    color: Colors.black,
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    "Vacaciones, Ausencias y Permisos",
                    style: TextStyle(
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.02),

            /// 🔹 FILTROS SUPERIORES
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterCard("Fecha", Icons.calendar_today, () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      print("📅 Fecha seleccionada en filtro: $date");
                      _filtroFecha = date;
                      _aplicarFiltros();
                    }
                  }),
                  _buildFilterCard(
                    "Tipo: $_filtroTipo",
                    Icons.category,
                    _mostrarDialogoSeleccionTipo,
                  ),
                  Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      onChanged: (v) {
                        _busqueda = v;
                        _aplicarFiltros();
                      },
                      decoration: const InputDecoration(
                        hintText: "Buscar ID o motivo...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.02),

            /// 🔹 BOTÓN SOLICITAR
            Center(
              child: SizedBox(
                width: width * 0.55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: height * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.solicitudes3);
                  },
                  child: Text(
                    "Crear Solicitud ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.0015),

            /// 🔹 LISTADO COMPLETO
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                itemCount: _solicitudesFiltradas.length,
                itemBuilder: (context, index) {
                  final item = _solicitudesFiltradas[index];
                  return _buildDetalleCard(item);
                },
              ),
            ),
            SizedBox(height: height * 0.06),
          ],
        ),
      ),
    );
  }

  /// 🔹 TARJETA FILTRO
  Widget _buildFilterCard(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF7B1522), Color(0xFFE41335)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 DIALOGO TIPO
  void _mostrarDialogoSeleccionTipo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final tipos = ["Todos", "Vacaciones", "Ausencia", "Permiso"];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔴 Header rojo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7B1522), Color(0xFFE41335)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: const Center(
                child: Text(
                  "Seleccionar tipo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Opciones
            ...tipos.map(
              (tipo) => ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color:
                      _filtroTipo == tipo
                          ? const Color(0xFFE41335)
                          : Colors.grey,
                ),
                title: Text(
                  tipo,
                  style: TextStyle(
                    fontWeight:
                        _filtroTipo == tipo
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _filtroTipo = tipo;
                  });
                  _aplicarFiltros();
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  /// 🔹 TARJETA DETALLE COMPLETO
  Widget _buildDetalleCard(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF7B1522), Color(0xFFE41335)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Nro de solicitud:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['id']?.toString() ?? "--",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    // 🔹 Ícono como el original
                    const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              Row(
                children: [
                  const Text(
                    "Tipo:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Text(item['tipoSolicitud'] ?? "--"),
                ],
              ),
              const SizedBox(height: 5),

              Row(
                children: [
                  const Text(
                    "Desde:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Text(_formatFecha(item['fechaInicio'])),
                ],
              ),
              const SizedBox(height: 5),

              Row(
                children: [
                  const Text(
                    "Hasta:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Text(_formatFecha(item['fechaFin'])),
                ],
              ),
              const SizedBox(height: 5),

              Row(
                children: [
                  const Text(
                    "Días:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Text(item['totalDias']?.toString() ?? "--"),
                ],
              ),
              const SizedBox(height: 5),

              Row(
                children: [
                  const Text(
                    "Estado:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Text(item['estado'] ?? "--"),
                ],
              ),
              const SizedBox(height: 5),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Motivo:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(item['motivo'] ?? "Sin motivo")),
                ],
              ),
            ],
          ),
        ),

        if (item['estado'] == 'Pendiente')
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => _confirmarEliminar(item['id']),
            ),
          ),

        // 🔹 Línea separadora EXACTA como la original
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.withOpacity(0.4),
          margin: const EdgeInsets.symmetric(vertical: 10),
        ),
      ],
    );
  }

  Widget _rowInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(value ?? "--"),
        ],
      ),
    );
  }
}
