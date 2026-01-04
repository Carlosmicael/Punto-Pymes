import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/solicitudes_service.dart';

class SolicitudVacaciones extends StatefulWidget {
  const SolicitudVacaciones({super.key});

  @override
  State<SolicitudVacaciones> createState() => _SolicitudVacacionesState();
}

class _SolicitudVacacionesState extends State<SolicitudVacaciones> {
  /// ---------------- ESTADO ----------------
  String _tipoSeleccionado = "Vacaciones";
  final List<String> _tipos = ["Vacaciones", "Ausencia", "Permiso"];

  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  final TextEditingController _motivoController = TextEditingController();
  List<PlatformFile> archivosAdjuntos = [];

  bool _isLoading = false;

  /// ---------------- FECHAS ----------------
  Future<void> _seleccionarRango() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      helpText: "Seleccionar rango de fechas",
    );

    if (picked != null) {
      setState(() {
        _fechaInicio = picked.start;
        _fechaFin = picked.end;
      });
    }
  }

  /// ---------------- ARCHIVOS ----------------
  Future<void> _seleccionarDocumentos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ["pdf", "doc", "docx", "jpg", "png"],
    );

    if (result != null) {
      setState(() {
        archivosAdjuntos.addAll(result.files);
      });
    }
  }

  /// ---------------- ENVIAR ----------------
  Future<void> _enviarSolicitud() async {
    if (_fechaInicio == null ||
        _fechaFin == null ||
        _motivoController.text.trim().isEmpty) {
      _mostrarResultadoDialog(
        exito: false,
        mensaje: "Complete todos los campos obligatorios.",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = SolicitudesService();

      await service.createSolicitud(
        tipoSolicitud: _tipoSeleccionado,
        fechaInicio: _fechaInicio!.toIso8601String(),
        fechaFin: _fechaFin!.toIso8601String(),
        motivo: _motivoController.text.trim(),
        adjuntos: archivosAdjuntos,
      );

      if (!mounted) return;

      _mostrarResultadoDialog(
        exito: true,
        mensaje: "Tu solicitud fue registrada correctamente.",
      );
    } catch (e) {
      _mostrarResultadoDialog(
        exito: false,
        mensaje:
            "Ocurrió un error al enviar la solicitud.\nInténtalo nuevamente.",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarResultadoDialog({required bool exito, required String mensaje}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  exito ? Icons.check_circle : Icons.error,
                  size: 70,
                  color: exito ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  exito ? "Solicitud enviada" : "Error al enviar",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          exito ? const Color(0xFFE41335) : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // cierra diálogo
                      if (exito) {
                        Navigator.pop(context); // vuelve a la pantalla anterior
                      }
                    },
                    child: Text(
                      exito ? "VOLVER" : "REINTENTAR",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.06,
            vertical: height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- HEADER ----------
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: width * 0.03),
                  const Text(
                    "Volver",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              SizedBox(height: height * 0.03),

              /// ---------- TÍTULO ----------
              Text(
                "Nueva solicitud",
                style: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              SizedBox(height: height * 0.035),

              /// ---------- TIPO ----------
              _buildCard(
                title: "Tipo de solicitud",
                child: DropdownButtonFormField<String>(
                  value: _tipoSeleccionado,
                  items:
                      _tipos
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _tipoSeleccionado = v!),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),

              SizedBox(height: height * 0.03),

              /// ---------- FECHAS ----------
              _buildCard(
                title: "Fechas",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _seleccionarRango,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _fechaInicio == null
                            ? "Seleccionar Rango"
                            : "${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}  -  "
                                "${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    if (_tipoSeleccionado == "Permiso")
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Nota: Para permisos por horas, especifique en el motivo.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              /// ---------- MOTIVO ----------
              _buildCard(
                title: "Motivo",
                child: TextField(
                  controller: _motivoController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Escriba el motivo...",
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),

              /// ---------- ADJUNTOS ----------
              _buildCard(
                title: "Adjuntar documentos",
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _seleccionarDocumentos,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: height * 0.03),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.upload_file, size: 40),
                            SizedBox(height: 8),
                            Text("Adjuntar archivos"),
                          ],
                        ),
                      ),
                    ),
                    if (archivosAdjuntos.isNotEmpty)
                      Column(
                        children:
                            archivosAdjuntos.map((f) {
                              return ListTile(
                                leading: const Icon(Icons.insert_drive_file),
                                title: Text(
                                  f.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      archivosAdjuntos.remove(f);
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.05),

              /// ---------- BOTÓN ----------
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE41335),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: _enviarSolicitud,
                      child: const Text(
                        "ENVIAR SOLICITUD",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

              SizedBox(height: height * 0.15),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- CARD REUTILIZABLE ----------
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
