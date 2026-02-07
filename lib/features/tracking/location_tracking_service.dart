import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auth_company/features/tracking/services/socket_service.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class LocationTrackingService {
  static StreamSubscription<Position>? _positionStream;




  static Timer? _umbralTimer;      
  static Timer? _exitTimer;        
  static Timer? _enterTimer;       

  static String _lastStatus = 'unknown'; 
  static bool _wasOutside = false;  
  static Position? _currentPosition;

  static DateTime? _exitTime;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Manejar tap en notificación si es necesario
      },
    );

    // Crear canal de notificaciones para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_tracking_channel',
      'Seguimiento de Ubicación',
      description: 'Notificaciones de entrada y salida de la sucursal',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }



  static Future<void> startTracking() async {

    const LocationSettings settings = LocationSettings(accuracy: LocationAccuracy.bestForNavigation,distanceFilter: 1,);

    _positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position position) async {
          _currentPosition = position;
      await _evaluatePosition(position);
    });
  }

  static Future<void> _evaluatePosition(Position position) async {
    final prefs = await SharedPreferences.getInstance();

    double? branchLat = prefs.getDouble('branchLat');
    double? branchLng = prefs.getDouble('branchLng');
    double? branchRadius = prefs.getDouble('branchRadius');
    double? threshold = prefs.getDouble('threshold');
    String? uid = prefs.getString('uid');
    String? companyId = prefs.getString('companyId');
    String? branchId = prefs.getString('branchId');

    if (branchLat == null || branchLng == null || branchRadius == null || threshold == null || uid == null || companyId == null || branchId == null) return;


    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      branchLat,
      branchLng,
    );

    double safeZone = branchRadius - threshold;
    String currentStatus;


    if (distance < safeZone) {
      print("🟢 Dentro de zona segura");
      currentStatus = 'safe';

    } else if (distance >= safeZone && distance <= branchRadius) {
      print("🟡 Dentro del UMBRAL → Activar rastreo");
      currentStatus = 'umbral';
 
    } else {
      print("🔴 FUERA DE LA SUCURSAL");
      currentStatus = 'outside';
    }

    if (currentStatus != _lastStatus) {
      await _handleStatusChange(currentStatus, position, distance, uid, companyId, branchId);
      _lastStatus = currentStatus;
    }



  }






  static Future<void> _handleStatusChange(String newStatus, Position position, double distance, String uid, String companyId, String branchId) async {
    
    _umbralTimer?.cancel();
    _exitTimer?.cancel();
    _enterTimer?.cancel();

    switch (newStatus) {
      case 'safe':
        // 🟢 ENTRÓ A ZONA SEGURA
        Fluttertoast.showToast(msg: "🟢 Zona segura", backgroundColor: Colors.green, textColor: Colors.white);
        

        if (_wasOutside) {
          
          _wasOutside = false;

          // ✅ MOSTRAR NOTIFICACIÓN DE REGRESO CON TIEMPO FUERA
          await _showReturnNotification();
          
          SocketService.emit('location:returned', {
            'uid': uid,
            'lat': position.latitude,
            'lng': position.longitude,
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'returned',
            'companyId': companyId,
            'branchId': branchId,
          });

          int count = 0;
          _enterTimer = Timer.periodic(Duration(seconds: 1), (timer) {
            count++;
            final currentPos = _currentPosition;
            if (currentPos == null) return; 
            SocketService.emit('location:update', {
              'uid': uid,
              'lat': currentPos.latitude,
              'lng': currentPos.longitude,
              'timestamp': DateTime.now().toIso8601String(),
              'status': 'entering',
              'secondsLeft': 5 - count,
              'companyId': companyId,
              'branchId': branchId,
            });
            
            if (count >= 5) {
              timer.cancel();
              print("⏹️ Entrada completada, cortando envío");
            }
          });
        } else {
          SocketService.emit('location:checkin', {
            'uid': uid,
            'lat': position.latitude,
            'lng': position.longitude,
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'safe',
            'companyId': companyId,
            'branchId': branchId,
          });
        }

        break;

      case 'umbral':
        // 🟡 ENTRÓ AL UMBRAL
        Fluttertoast.showToast(msg: "🟡 Umbral - Tracking activo", backgroundColor: Colors.orange, textColor: Colors.white);

        
        SocketService.emit('location:tracking', {
          'uid': uid,
          'lat': position.latitude,
          'lng': position.longitude,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'umbral',
          'distance': distance,
          'companyId': companyId,
          'branchId': branchId,
        });

        _umbralTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          final currentPos = _currentPosition;
          if (currentPos == null) return; 
          SocketService.emit('location:tracking', {
            'uid': uid,
            'lat': currentPos.latitude,
            'lng': currentPos.longitude,
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'umbral',
            'distance': distance,
            'companyId': companyId,
            'branchId': branchId,
          });
        });
        break;


      case 'outside':
        // 🔴 SALIÓ DE LA SUCURSAL
        Fluttertoast.showToast(msg: "🔴 Fuera de sucursal", backgroundColor: Colors.red, textColor: Colors.white);
        _wasOutside = true;
        _exitTime = DateTime.now(); 
        
        // ✅ MOSTRAR NOTIFICACIÓN DE SALIDA
        await _showExitNotification();
        await _saveExitRecord(uid, position, companyId, branchId);

        SocketService.emit('location:exited', {
          'uid': uid,
          'lat': position.latitude,
          'lng': position.longitude,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'exited',
          'distance': distance,
          'companyId': companyId,
          'branchId': branchId,
        });

        int count = 0;
        _exitTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          count += 1;
          final currentPos = _currentPosition;
          if (currentPos == null) return; 
  
          SocketService.emit('location:final', {
            'uid': uid,
            'lat': currentPos.latitude,
            'lng': currentPos.longitude,
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'outside',
            'secondsElapsed': count,
            'isLast': count >= 15,
            'companyId': companyId,
            'branchId': branchId,
          });
          
          if (count >= 15) {
            timer.cancel();
            print("⏹️ Tracking finalizado");
          }
        });
        break;
    }

  }





  // ✅ NOTIFICACIÓN DE SALIDA - ATRACTIVA Y PROFESIONAL
  static Future<void> _showExitNotification() async {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'location_tracking_channel',
      'Seguimiento de Ubicación',
      channelDescription: 'Notificaciones de entrada y salida de la sucursal',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      when: null, // Usar hora actual
      color: Color(0xFFF44336), // Rojo
      ledColor: Color(0xFFF44336),
      ledOnMs: 1000,
      ledOffMs: 500,
      enableLights: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        'Has salido de la sucursal a las $timeString. Tu ubicación está siendo rastreada por seguridad.',
        contentTitle: '🔴 Fuera de la sucursal',
        summaryText: 'Seguimiento activado',
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      1, // ID de la notificación
      '🔴 Fuera de la sucursal',
      'Salida registrada a las $timeString. Rastreo activo por seguridad.',
      notificationDetails,
      payload: 'exit',
    );
  }




  // ✅ NOTIFICACIÓN DE REGRESO - CON TIEMPO FUERA CALCULADO
  static Future<void> _showReturnNotification() async {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    String timeOutsideText = '';
    if (_exitTime != null) {
      final difference = now.difference(_exitTime!);
      final minutes = difference.inMinutes;
      final seconds = difference.inSeconds % 60;
      
      if (minutes > 0) {
        timeOutsideText = '$minutes min ${seconds}s';
      } else {
        timeOutsideText = '$seconds segundos';
      }
    } else {
      timeOutsideText = 'Tiempo desconocido';
    }

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'location_tracking_channel',
      'Seguimiento de Ubicación',
      channelDescription: 'Notificaciones de entrada y salida de la sucursal',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      color: Color(0xFF4CAF50), // Verde
      ledColor: Color(0xFF4CAF50),
      ledOnMs: 1000,
      ledOffMs: 500,
      enableLights: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 100, 300]),
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        'Has regresado a las $timeString. Estuviste fuera: $timeOutsideText',
        contentTitle: '🟢 De vuelta en la sucursal',
        summaryText: 'Bienvenido de vuelta',
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 0, // Limpiar badge al regresar
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      2, // ID diferente para no sobreescribir la de salida
      '🟢 De vuelta en la sucursal',
      'Regreso registrado a las $timeString. Duración fuera: $timeOutsideText',
      notificationDetails,
      payload: 'return',
    );
    
    _exitTime = null;
  }

  static Future<void> _saveExitRecord(String uid, Position position, String companyId, String branchId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList('exit_records') ?? [];
    
    records.add(jsonEncode({
      'uid': uid,
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
      'companyId': companyId,
      'branchId': branchId,
    }));
    
    await prefs.setStringList('exit_records', records);
  }




  static void stopTracking() {
    _positionStream?.cancel();
    _umbralTimer?.cancel();
    _exitTimer?.cancel();
    _enterTimer?.cancel();
    _currentPosition = null;
  }

  static Future<void> restartTracking() async {
    stopTracking();
    _lastStatus = 'unknown';
    await startTracking();
  }
}

