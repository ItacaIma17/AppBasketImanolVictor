// lib/services/logger_service.dart
import 'package:flutter/foundation.dart';

enum LogLevel {
  DEBUG,
  INFO,
  WARNING,
  ERROR,
}

class LoggerService {
  static const String _defaultTag = 'APP_BASKET';
  static bool _enableDebugLogs = true;
  static bool _enableFileLogging = false; // Opcional: para guardar logs en archivo

  // Configuración
  static void setDebugMode(bool enabled) {
    _enableDebugLogs = enabled;
  }

  static void enableFileLogging(bool enabled) {
    _enableFileLogging = enabled;
  }

  // Métodos principales
  static void debug(String message, {String? tag, Map<String, dynamic>? data}) {
    if (!_enableDebugLogs) return;
    _log(LogLevel.DEBUG, message, tag: tag, data: data);
  }

  static void info(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.INFO, message, tag: tag, data: data);
  }

  static void warning(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.WARNING, message, tag: tag, data: data);
  }

  static void error(String message, {String? tag, dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _log(LogLevel.ERROR, message, tag: tag, error: error, stackTrace: stackTrace, data: data);
  }

  // Logs específicos para API
  static void apiCall(String method, String url, {int? statusCode, dynamic request, dynamic response, dynamic error, Duration? duration}) {
    final data = <String, dynamic>{
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'duration': duration?.inMilliseconds,
    };

    if (request != null) data['request'] = _truncate(request.toString());
    if (response != null) data['response'] = _truncate(response.toString());
    if (error != null) data['error'] = error.toString();

    if (error != null || (statusCode != null && statusCode >= 400)) {
      error('🌐 API CALL FAILED', tag: 'API', data: data, error: error);
    } else {
      info('🌐 API CALL', tag: 'API', data: data);
    }
  }

  // Logs para navegación
  static void navigation(String from, String to, {Map<String, dynamic>? params}) {
    info('🧭 NAVEGACIÓN: $from -> $to', tag: 'NAV', data: params);
  }

  // Logs para autenticación
  static void auth(String action, {String? username, String? email, Map<String, dynamic>? data}) {
    final authData = <String, dynamic>{'action': action};
    if (username != null) authData['username'] = username;
    if (email != null) authData['email'] = email;
    if (data != null) authData.addAll(data);

    info('🔐 AUTENTICACIÓN: $action', tag: 'AUTH', data: authData);
  }

  // Logs para base de datos local
  static void db(String operation, String table, {Map<String, dynamic>? data, dynamic error}) {
    final dbData = <String, dynamic>{'operation': operation, 'table': table};
    if (data != null) dbData['data'] = _truncate(data.toString());
    if (error != null) {
      error('💾 DB ERROR', tag: 'DB', data: dbData, error: error);
    } else {
      debug('💾 DB OPERATION', tag: 'DB', data: dbData);
    }
  }

  // Logs para almacenamiento local (SharedPreferences)
  static void storage(String action, String key, {dynamic value, dynamic error}) {
    final storageData = <String, dynamic>{'action': action, 'key': key};
    if (value != null) storageData['value'] = _truncate(value.toString());
    if (error != null) {
      error('💾 STORAGE ERROR', tag: 'STORAGE', data: storageData, error: error);
    } else {
      debug('💾 STORAGE', tag: 'STORAGE', data: storageData);
    }
  }

  // Logs para eventos del usuario
  static void userAction(String action, {Map<String, dynamic>? details}) {
    info('👆 USUARIO: $action', tag: 'UI', data: details);
  }

  // Logs para errores de red
  static void networkError(String message, {String? url, dynamic error, StackTrace? stackTrace}) {
    error('📡 NETWORK ERROR: $message', tag: 'NETWORK',
        error: error, stackTrace: stackTrace,
        data: url != null ? {'url': url} : null);
  }

  // Método interno de logging
  static void _log(LogLevel level, String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data
  }) {
    if (!kDebugMode && level == LogLevel.DEBUG) return;

    final String timestamp = DateTime.now().toIso8601String();
    final String levelStr = _getLevelString(level);
    final String tagStr = tag != null ? '[$tag]' : '';
    final String finalTag = tagStr.isNotEmpty ? tagStr : '[$_defaultTag]';

    final String logMessage = '$timestamp $levelStr $finalTag $message';

    // Colores para consola (opcional)
    switch (level) {
      case LogLevel.DEBUG:
        debugPrint('\x1B[36m🔍 $logMessage\x1B[0m'); // Cyan
        break;
      case LogLevel.INFO:
        debugPrint('\x1B[32mℹ️ $logMessage\x1B[0m'); // Verde
        break;
      case LogLevel.WARNING:
        debugPrint('\x1B[33m⚠️ $logMessage\x1B[0m'); // Amarillo
        break;
      case LogLevel.ERROR:
        debugPrint('\x1B[31m❌ $logMessage\x1B[0m'); // Rojo
        break;
    }

    // Imprimir datos adicionales
    if (data != null && data.isNotEmpty) {
      debugPrint('   📊 Data: ${_formatData(data)}');
    }

    // Imprimir error si existe
    if (error != null) {
      debugPrint('   🐛 Error: $error');
      if (stackTrace != null) {
        debugPrint('   📚 StackTrace: $stackTrace');
      }
    }

    // Opcional: Guardar en archivo
    if (_enableFileLogging) {
      _saveToFile(logMessage, data, error, stackTrace);
    }
  }

  static String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.DEBUG: return 'DEBUG';
      case LogLevel.INFO: return 'INFO ';
      case LogLevel.WARNING: return 'WARN ';
      case LogLevel.ERROR: return 'ERROR';
    }
  }

  static String _formatData(Map<String, dynamic> data) {
    try {
      final formatted = <String, String>{};
      data.forEach((key, value) {
        String strValue = value.toString();
        if (strValue.length > 100) {
          strValue = strValue.substring(0, 100) + '...';
        }
        formatted[key] = strValue;
      });
      return formatted.toString();
    } catch (e) {
      return data.toString();
    }
  }

  static String _truncate(String text, {int maxLength = 200}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}... (${text.length - maxLength} más)';
  }

  static Future<void> _saveToFile(String message, Map<String, dynamic>? data, dynamic error, StackTrace? stackTrace) async {
    // Implementación opcional para guardar logs en archivo
    // Puedes usar package:path_provider para obtener el directorio de documentos
    // y escribir los logs en un archivo .log
  }

  // Método para medir tiempo de ejecución
  static Future<T> measureTime<T>(String operation, Future<T> Function() callback) async {
    final startTime = DateTime.now();
    info('⏱️ INICIO: $operation', tag: 'PERF');

    try {
      final result = await callback();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      info('✅ FIN: $operation - Duración: ${duration.inMilliseconds}ms', tag: 'PERF');
      return result;
    } catch (e, stackTrace) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      error('❌ ERROR en $operation - Duración: ${duration.inMilliseconds}ms',
          tag: 'PERF', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Limpiar logs antiguos (opcional)
  static Future<void> cleanOldLogs() async {
    // Implementación para limpiar logs de más de X días
    debug('Limpiando logs antiguos', tag: 'LOGGER');
  }
}

// Extensión para facilitar el uso
extension LoggerExtension on Object {
  void logDebug(String message, {String? tag, Map<String, dynamic>? data}) {
    LoggerService.debug(message, tag: tag ?? runtimeType.toString(), data: data);
  }

  void logInfo(String message, {String? tag, Map<String, dynamic>? data}) {
    LoggerService.info(message, tag: tag ?? runtimeType.toString(), data: data);
  }

  void logWarning(String message, {String? tag, Map<String, dynamic>? data}) {
    LoggerService.warning(message, tag: tag ?? runtimeType.toString(), data: data);
  }

  void logError(String message, {String? tag, dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    LoggerService.error(message, tag: tag ?? runtimeType.toString(), error: error, stackTrace: stackTrace, data: data);
  }
}