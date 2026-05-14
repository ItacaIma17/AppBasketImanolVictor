import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'RestablecerContrasenaPage.dart';

class OlvidarContrasenaPage extends StatefulWidget {
  const OlvidarContrasenaPage({super.key});

  @override
  State<OlvidarContrasenaPage> createState() => _OlvidarContrasenaPageState();
}

class _OlvidarContrasenaPageState extends State<OlvidarContrasenaPage> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce tu email'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AutenticacionService.olvidarContrasena(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código enviado a tu email'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RestablecerContrasenaPage(email: email),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.lock_reset, size: 80, color: AppColors.blanco),
                      SizedBox(height: 16),
                      Text(
                        'RECUPERAR CONTRASEÑA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.blanco,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Introduce tu email y te enviaremos\nun código de recuperación.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.blancoOpacidad70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle: TextStyle(color: AppColors.blancoOpacidad70),
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.blancoOpacidad70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blancoOpacidad54),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blanco),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : _enviarCodigo,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'ENVIAR CÓDIGO',
                            style: TextStyle(
                              color: AppColors.blanco,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}