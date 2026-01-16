/// Dirección IP del backend 
const String serverIp = "192.168.1.6";

/// Puerto del backend principal (NestJS)
const int serverPort = 3000;

/// Path específico para attendance
const String attendancePath = "attendance"; 

/// URL base para endpoints generales
String baseUrll = "http://$serverIp:$serverPort";

/// URL base para attendance
String attendanceUrl = "http://$serverIp:$serverPort/$attendancePath"; 

/// URL base para sucursales
String sucursalesUrl = "$baseUrll/sucursales";

/// URL base para kpis
const String kpisPath = "kpis";
String kpisUrl = "$baseUrll/$kpisPath";

/// URL base para horarios
const String horariosPath = "horarios";
String horariosUrl = "$baseUrll/$horariosPath";

/// URL base para notificaciones
const String notificacionesPath = "notificaciones";
String notificacionesUrl = "$baseUrll/$notificacionesPath"; 
