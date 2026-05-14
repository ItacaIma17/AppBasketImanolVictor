import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/models/usuario.dart';

import '../models/role.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _mostrarOldPassword = false;
  bool _mostrarNewPassword = false;
  bool _mostrarConfirmPassword = false;
  bool _cambiarPassword = false;

  Usuario? _usuarioActual;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _edadController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuario() async {
    final usuario = await AutenticacionService.obtenerUsuarioActual();
    setState(() {
      _usuarioActual = usuario;
      if (usuario != null) {
        _usernameController.text = usuario.username;
        _nombreController.text = usuario.nombre;
        _apellidoController.text = usuario.apellido ?? '';
        _edadController.text = usuario.edad > 0 ? usuario.edad.toString() : '';
      }
    });
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? nuevoUsername;
      String? nuevoNombre;
      String? nuevoApellido;
      int? nuevaEdad;
      String? oldPassword;
      String? newPassword;

      if (_usernameController.text != _usuarioActual?.username) {
        nuevoUsername = _usernameController.text;
      }
      if (_nombreController.text.isNotEmpty &&
          _nombreController.text != _usuarioActual?.nombre) {
        nuevoNombre = _nombreController.text;
      }
      if (_apellidoController.text != (_usuarioActual?.apellido ?? '')) {
        nuevoApellido = _apellidoController.text;
      }
      if (_edadController.text.isNotEmpty) {
        final edadParsed = int.tryParse(_edadController.text);
        if (edadParsed != null && edadParsed != _usuarioActual?.edad) {
          nuevaEdad = edadParsed;
        }
      }
      if (_cambiarPassword) {
        oldPassword = _oldPasswordController.text;
        newPassword = _newPasswordController.text;
      }

      await AutenticacionService.actualizarPerfil(
        username: nuevoUsername,
        nombre: nuevoNombre,
        apellido: nuevoApellido,
        edad: nuevaEdad,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_usuarioActual == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppColors.naranja,
        foregroundColor: AppColors.blanco,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _guardarCambios,
            child: const Text(
              'Guardar',
              style: TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildInfoCard(),
                  const SizedBox(height: 20),

                  _buildDatosPersonalesSection(),
                  const SizedBox(height: 20),

                  _buildUsernameSection(),
                  const SizedBox(height: 20),

                  _buildPasswordSection(),
                  const SizedBox(height: 30),

                  _buildSaveButton(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.naranja),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: AppColors.naranja),
                SizedBox(width: 8),
                Text(
                  'Información de la Cuenta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(Icons.email, 'Email', _usuarioActual!.email),
            _buildInfoRow(Icons.person, 'Nombre', _usuarioActual!.nombreCompleto),
            _buildInfoRow(Icons.badge, 'Rol', _usuarioActual!.role.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.naranja),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildDatosPersonalesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit, color: AppColors.naranja),
                SizedBox(width: 8),
                Text(
                  'Datos Personales',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'El nombre no puede estar vacío';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _edadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Edad',
                prefixIcon: Icon(Icons.cake_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final n = int.tryParse(v);
                  if (n == null || n < 1 || n > 120) return 'Edad no válida';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.naranja),
                SizedBox(width: 8),
                Text(
                  'Cambiar Nombre de Usuario',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nuevo nombre de usuario',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre de usuario no puede estar vacío';
                }
                if (value.length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return 'Solo letras, números y _';
                }
                return null;
              },
            ),
            if (_usernameController.text != _usuarioActual?.username)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  ' Tu nombre de usuario actual es: ${_usuarioActual?.username}',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, color: AppColors.naranja),
                const SizedBox(width: 8),
                const Text(
                  'Cambiar Contraseña',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: _cambiarPassword,
                  onChanged: (value) {
                    setState(() {
                      _cambiarPassword = value;
                      if (!value) {
                        _oldPasswordController.clear();
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();
                      }
                    });
                  },
                  activeColor: AppColors.naranja,
                ),
              ],
            ),
            if (_cambiarPassword) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_mostrarOldPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_mostrarOldPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _mostrarOldPassword = !_mostrarOldPassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_cambiarPassword && (value == null || value.isEmpty)) {
                    return 'Ingresa tu contraseña actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_mostrarNewPassword,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_mostrarNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _mostrarNewPassword = !_mostrarNewPassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_cambiarPassword) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu nueva contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Al menos una mayúscula';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Al menos un número';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_mostrarConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_mostrarConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _mostrarConfirmPassword = !_mostrarConfirmPassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_cambiarPassword) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma tu nueva contraseña';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {

    final hasChanges = _usernameController.text != _usuarioActual?.username ||
        _nombreController.text != (_usuarioActual?.nombre ?? '') ||
        _apellidoController.text != (_usuarioActual?.apellido ?? '') ||
        _edadController.text != (_usuarioActual?.edad.toString() ?? '') ||
        _cambiarPassword;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.naranja,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: (!hasChanges || _isLoading) ? null : _guardarCambios,
        child: const Text(
          'GUARDAR CAMBIOS',
          style: TextStyle(
            color: AppColors.blanco,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
