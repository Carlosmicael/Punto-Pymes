/// Dirección IP del backend 
const String serverIp = "172.17.161.254";

/// Puerto del backend principal (NestJS)
const int serverPort = 3000;

/// Path específico para attendance
const String attendancePath = "attendance"; 

/// URL base para endpoints generales
String baseUrll = "http://$serverIp:$serverPort";

/// URL base para attendance
String attendanceUrl = "http://$serverIp:$serverPort/$attendancePath"; 
