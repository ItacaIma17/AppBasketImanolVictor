import 'package:flutter/material.dart';
import '../services/autenticacion_service.dart';
import '../services/loggerService.dart';
import 'Admin/PanelAdminPage.dart';
import 'Entrenador/PanelEntrenadorPage.dart';
import 'InicioApp.dart';

class VerificacionPage extends StatefulWidget {
  final String email;

  const VerificacionPage({super.key, required this.email});

  @override
  State<VerificacionPage> createState() => _VerificacionPageState();
}

class _VerificacionPageState extends State<VerificacionPage> {
  final TextEditingController _codigoController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  int _attempts = 0;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _verificarCodigo() async {
    final codigo = _codigoController.text.trim();

    LoggerService.info('Intentando verificar código', tag: 'VERIFICACION', data: {
      'email': widget.email,
      'codigo': codigo,
      'intento': _attempts + 1,
    });

    if (codigo.isEmpty) {
      setState(() => _error = 'Por favor ingresa el código de verificación');
      return;
    }

    if (codigo.length != 6) {
      setState(() => _error = 'El código debe tener 6 dígitos');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _attempts++;
    });

    try {
      final response = await AutenticacionService.verificarCodigo(codigo, widget.email);

      LoggerService.info('Respuesta de verificación', tag: 'VERIFICACION', data: {
        'success': response != null,
        'role': response?.rol,
      });

      if (response != null && mounted) {

        final usuario = AutenticacionService.usuarioActual;

        LoggerService.info('Verificación exitosa', tag: 'VERIFICACION', data: {
          'username': usuario?.username,
          'role': usuario?.role.toString(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Cuenta verificada exitosamente'), backgroundColor: Colors.green),
        );

        if (usuario?.isAdmin == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PanelAdminPage()),
          );
        } else if (usuario?.isEntrenador == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PanelEntrenadorPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InicioPage()),
          );
        }
      } else if (mounted) {
        setState(() => _error = 'Código inválido o expirado');
        LoggerService.warning('Código inválido', tag: 'VERIFICACION', data: {
          'email': widget.email,
          'codigo': codigo,
          'attempts': _attempts,
        });
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error en verificación', tag: 'VERIFICACION',
          error: e, stackTrace: stackTrace, data: {'email': widget.email});
      setState(() => _error = 'Error al verificar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reenviarCodigo() async {
    LoggerService.info('Reenviando código', tag: 'VERIFICACION', data: {'email': widget.email});

    setState(() => _isLoading = true);

    try {
      await AutenticacionService.reenviarCodigo(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Código reenviado a tu email'), backgroundColor: Colors.orange),
        );
        LoggerService.info('Código reenviado exitosamente', tag: 'VERIFICACION');
      }
    } catch (e) {
      LoggerService.error('Error reenviando código', tag: 'VERIFICACION', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.verified_user, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              'Verifica tu cuenta',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Hemos enviado un código de verificación a:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              widget.email,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _codigoController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 4),
              decoration: InputDecoration(
                labelText: 'Código de 6 dígitos',
                hintText: 'Ej: 123456',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verificarCodigo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verificar', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _reenviarCodigo,
              child: const Text('Reenviar código'),
            ),
          ],
        ),
      ),
    );
  }
}
