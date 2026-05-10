import '../config/api_config.dart';
import 'loggerService.dart';

class UsuarioService {

  static Future<List<dynamic>> listarArbitros() async {
    try {
      final response = await AppConfig.get('/usuarios/arbitros');

      if (response == null) return [];

      final List<dynamic> data = response is List ? response : [];

      return data;
    } catch (e) {
      LoggerService.error('Error obteniendo árbitros', tag: 'USUARIO', error: e);
      return [];
    }
  }
}
