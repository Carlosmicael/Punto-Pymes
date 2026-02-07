import 'package:auth_company/config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:auth_company/features/auth/login/login_service.dart';
import 'package:auth_company/features/tracking/location_tracking_service.dart';
import 'package:auth_company/features/tracking/services/branch_config_service.dart';
import 'package:auth_company/auth_storage.dart';


class SocketService {
  static late IO.Socket socket;
  static String? _currentBranchId;





  static void emit(String event, Map<String, dynamic> data) {
    if (socket.connected) {
      socket.emit(event, data);
      print("📤 Emitido '$event': $data");
    } else {
      print("⚠️ Socket desconectado, no se pudo emitir '$event'");
    }
  }








  static void connect({required String userId, required String companyId, required String branchId}) {

    _currentBranchId = branchId;

    socket = IO.io("http://$serverIp:$serverPort",

      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().setAuth({"uid": userId,"companyId": companyId,"branchId": branchId,}).build(),
    );

    socket.onConnect((_) {print("🟢 Conectado al servidor WebSocket");});



    socket.on("employeeUpdated", (data) async {
      
        print("👤 Empleado actualizado: $data");
        final newBranchId = data['branchId'];
        
        if (newBranchId != null && newBranchId != _currentBranchId) {
            print("🔄 Cambio de sucursal detectado: $_currentBranchId -> $newBranchId");      

            disconnect();
            
            await Future.delayed(const Duration(milliseconds: 500));
            connect(
                userId: userId,
                companyId: companyId,
                branchId: newBranchId,
            );
            return;
        }
        
        await _actualizarConfig();
    });


    socket.on("branchUpdated", (data) async {
        print("📍 Sucursal actualizada: $data");
        await _actualizarConfig();
    });  

    

  }




  static Future<void> _actualizarConfig() async {
    final token = await AuthStorage.getToken();
    final newBranchData = await LoginService().getBranchConfig(token!);

    await BranchConfigService.saveBranchConfig(
      lat: (newBranchData['latitud'] as num).toDouble(),
      lng: (newBranchData['longitud'] as num).toDouble(),
      radius: (newBranchData['rangoGeografico'] as num).toDouble(),
      threshold: (newBranchData['umbral'] as num).toDouble(),
      uid: newBranchData['uid'],
      companyId: newBranchData['companyId'],
      branchId: newBranchData['branchId'],
    );

    await LocationTrackingService.restartTracking();
  }

  static void disconnect() {
    socket.disconnect();
    socket.dispose();
    _currentBranchId = null;
  }

}



