import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SolicitudVacaciones extends StatefulWidget {
  const SolicitudVacaciones({super.key});

  @override
  State<SolicitudVacaciones> createState() => _SolicitudVacacionesState();
}

class _SolicitudVacacionesState extends State<SolicitudVacaciones> {
  final List<DateTime> fechasSeleccionadas = [];
  final TextEditingController motivoController = TextEditingController();

  List<PlatformFile> archivosAdjuntos = [];

  // 📌 Seleccionar fecha individual
  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: "Seleccionar día",
    );

    if (fecha != null) {
      if (!fechasSeleccionadas.contains(fecha)) {
        setState(() {
          fechasSeleccionadas.add(fecha);
          fechasSeleccionadas.sort((a, b) => a.compareTo(b));
        });
      }
    }
  }

  // 📌 Seleccionar documentos
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
              // ---------- HEADER ----------
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back, size: 22),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    "Volver",
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.03),

              // ---------- TÍTULO ----------
              Text(
                "Nueva solicitud",
                style: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),

              SizedBox(height: height * 0.035),

              // ---------- CARD FECHAS ----------
              _buildCard(
                title: "Seleccionar días",
                child: Container(
                  width: double.infinity, // 👈 MISMO ANCHO QUE TODAS LAS CARDS
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botón con degradado
                      GestureDetector(
                        onTap: _seleccionarFecha,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFE41335), Color(0xFF7B1522)],
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _seleccionarFecha,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              "Agregar fecha",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.020,
                                horizontal: width * 0.05,
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Lista de fechas
                      if (fechasSeleccionadas.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              fechasSeleccionadas.map((f) {
                                return Container(
                                  width:
                                      double
                                          .infinity, // 👈 CADA ITEM TAMBIÉN TOMA EL MISMO ANCHO
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.symmetric(
                                    vertical: height * 0.015,
                                    horizontal: width * 0.03,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "${f.day}/${f.month}/${f.year}",
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            fechasSeleccionadas.remove(f);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),

              // ---------- CARD MOTIVO ----------
              _buildCard(
                title: "Motivo de la solicitud",
                child: Container(
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: motivoController,
                    maxLines: 6,
                    style: TextStyle(fontSize: width * 0.04),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Escriba el motivo...",
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),

              // ---------- CARD DOCUMENTOS ----------
              _buildCard(
                title: "Adjuntar documentos",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _seleccionarDocumentos,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: height * 0.035),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 45,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(height: height * 0.01),
                            Text(
                              "Adjuntar archivos",
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    if (archivosAdjuntos.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            archivosAdjuntos.map((file) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.symmetric(
                                  vertical: height * 0.015,
                                  horizontal: width * 0.03,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file),
                                    SizedBox(width: width * 0.03),

                                    // Nombre del archivo
                                    Expanded(
                                      child: Text(
                                        file.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    // ---------- BOTÓN QUITAR ----------
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          archivosAdjuntos.remove(file);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.05),

              // ------------------ BOTÓN ------------------
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: width * 0.55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: height * 0.025),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Enviar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  // ---------- TARJETA REUTILIZABLE ----------
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
