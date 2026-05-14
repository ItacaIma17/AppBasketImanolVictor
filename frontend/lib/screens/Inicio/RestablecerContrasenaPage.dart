import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'InicioSesion.dart';

class RestablecerContrasenaPage extends StatefulWidget {
  final String email;

  const RestablecerContrasenaPage({super.key, required this.email});

  @override
  State<RestablecerContrasenaPage> createState() => _RestablecerContrasenaPageState();
}

class _RestablecerContrasenaPageState extends State<RestablecerContrasenaPage> {
  final _codigoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _mostrarPassword = false;
  bool _mostrarConfirm = false;

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _restablecer() async {
    final codigo = _codigoCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (codigo.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos'), backgroundColor: Colors.red),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mínimo 6 caracteres'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AutenticacionService.restablecerContrasena(widget.email, codigo, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña restablecida correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const InicioSesionPage()),
          (_) => false,
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
                      Icon(Icons.lock_open, size: 80, color: AppColors.blanco),
                      SizedBox(height: 16),
                      Text(
                        'NUEVA CONTRASEÑA',
                        style: TextStyle(
                          color: AppColors.blanco,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Código enviado a ${widget.email}',
                    style: const TextStyle(color: AppColors.blancoOpacidad70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _codigoCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: const InputDecoration(
                    labelText: 'Código de verificación',
                    labelStyle: TextStyle(color: AppColors.blancoOpacidad70),
                    prefixIcon: Icon(Icons.pin, color: AppColors.blancoOpacidad70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blancoOpacidad54),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blanco),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: !_mostrarPassword,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    labelStyle: const TextStyle(color: AppColors.blancoOpacidad70),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.blancoOpacidad70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.blancoOpacidad70,
                      ),
                      onPressed: () => setState(() => _mostrarPassword = !_mostrarPassword),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blancoOpacidad54),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blanco),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _confirmCtrl,
                  obscureText: !_mostrarConfirm,
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    labelStyle: const TextStyle(color: AppColors.blancoOpacidad70),
                    prefixIcon: const Icon(Icons.lock, color: AppColors.blancoOpacidad70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarConfirm ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.blancoOpacidad70,
                      ),
                      onPressed: () => setState(() => _mostrarConfirm = !_mostrarConfirm),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blancoOpacidad54),
                    ),
                    focusedBorder: const UnderlineInputBorder(
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
                    onPressed: _isLoading ? null : _restablecer,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'RESTABLECER CONTRASEÑA',
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