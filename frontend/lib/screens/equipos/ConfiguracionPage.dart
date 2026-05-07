// lib/screens/Admin/ConfiguracionPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/role.dart';
import '../../widgets/Header.dart';
import '../../widgets/MenuLateral.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool _notificacionesEmail = true;
  bool _notificacionesPush = true;
  bool _notificacionesPartidos = true;
  bool _perfilPublico = true;
  bool _mostrarEmail = false;
  String _idiomaSeleccionado = 'es';
  String _temaSeleccionado = 'claro';
  String _tamanoFuente = 'medio';
  bool _autenticacionBiometrica = false;
  bool _recordarSesion = true;
  bool _isLoading = false;

  final List<Map<String, String>> _idiomas = [
    {'codigo': 'es', 'nombre': 'Español'},
    {'codigo': 'en', 'nombre': 'English'},
    {'codigo': 'fr', 'nombre': 'Français'},
    {'codigo': 'pt', 'nombre': 'Português'},
  ];

  final List<Map<String, String>> _temas = [
    {'codigo': 'claro', 'nombre': 'Claro', 'icono': '☀️'},
    {'codigo': 'oscuro', 'nombre': 'Oscuro', 'icono': '🌙'},
    {'codigo': 'sistema', 'nombre': 'Sistema', 'icono': '📱'},
  ];

  final List<Map<String, String>> _fuentes = [
    {'codigo': 'pequeno', 'nombre': 'Pequeño', 'tamano': '12'},
    {'codigo': 'medio', 'nombre': 'Mediano', 'tamano': '14'},
    {'codigo': 'grande', 'nombre': 'Grande', 'tamano': '16'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificacionesEmail = prefs.getBool('notificaciones_email') ?? true;
      _notificacionesPush = prefs.getBool('notificaciones_push') ?? true;
      _notificacionesPartidos = prefs.getBool('notificaciones_partidos') ?? true;
      _perfilPublico = prefs.getBool('perfil_publico') ?? true;
      _mostrarEmail = prefs.getBool('mostrar_email') ?? false;
      _idiomaSeleccionado = prefs.getString('idioma') ?? 'es';
      _temaSeleccionado = prefs.getString('tema') ?? 'claro';
      _tamanoFuente = prefs.getString('tamano_fuente') ?? 'medio';
      _autenticacionBiometrica = prefs.getBool('auth_biometrica') ?? false;
      _recordarSesion = prefs.getBool('recordar_sesion') ?? true;
    });
  }

  Future<void> _guardarConfiguracion(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> _cambiarContrasena() async {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña actual'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordCtrl,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordCtrl,
              decoration: const InputDecoration(labelText: 'Confirmar nueva contraseña'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contraseña actualizada'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportarDatos() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos exportados correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _limpiarCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Caché'),
        content: const Text('¿Eliminar todos los datos temporales de la app?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Limpiar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cache_equipos');
        await prefs.remove('cache_partidos');
        await prefs.remove('cache_ligas');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Caché limpiada correctamente'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await AutenticacionService.cerrarSesion();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: const HeaderApp(titulo: "Configuración"),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteAragon),
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildPerfilUsuario(),
                            const SizedBox(height: 16),
                            _buildConfigSection('NOTIFICACIONES', Icons.notifications_active, [
                              SwitchListTile(
                                title: const Text('Notificaciones por Email'),
                                subtitle: const Text('Recibir alertas por correo electrónico'),
                                value: _notificacionesEmail,
                                onChanged: (v) {
                                  setState(() => _notificacionesEmail = v);
                                  _guardarConfiguracion('notificaciones_email', v);
                                },
                                activeColor: AppColors.naranja,
                              ),
                              SwitchListTile(
                                title: const Text('Notificaciones Push'),
                                subtitle: const Text('Recibir notificaciones en la app'),
                                value: _notificacionesPush,
                                onChanged: (v) {
                                  setState(() => _notificacionesPush = v);
                                  _guardarConfiguracion('notificaciones_push', v);
                                },
                                activeColor: AppColors.naranja,
                              ),
                              SwitchListTile(
                                title: const Text('Recordatorios de Partidos'),
                                subtitle: const Text('Recibir recordatorios antes de los partidos'),
                                value: _notificacionesPartidos,
                                onChanged: (v) {
                                  setState(() => _notificacionesPartidos = v);
                                  _guardarConfiguracion('notificaciones_partidos', v);
                                },
                                activeColor: AppColors.naranja,
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildConfigSection('PRIVACIDAD', Icons.privacy_tip, [
                              SwitchListTile(
                                title: const Text('Perfil Público'),
                                subtitle: const Text('Permitir que otros usuarios vean tu perfil'),
                                value: _perfilPublico,
                                onChanged: (v) {
                                  setState(() => _perfilPublico = v);
                                  _guardarConfiguracion('perfil_publico', v);
                                },
                                activeColor: AppColors.naranja,
                              ),
                              SwitchListTile(
                                title: const Text('Mostrar Email en Perfil'),
                                subtitle: const Text('Permitir que otros usuarios vean tu email'),
                                value: _mostrarEmail,
                                onChanged: (v) {
                                  setState(() => _mostrarEmail = v);
                                  _guardarConfiguracion('mostrar_email', v);
                                },
                                activeColor: AppColors.naranja,
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildConfigSection('APARIENCIA', Icons.palette, [
                              ListTile(
                                title: const Text('Idioma'),
                                subtitle: Text(_idiomas.firstWhere((i) => i['codigo'] == _idiomaSeleccionado)['nombre'] ?? 'Español'),
                                trailing: DropdownButton<String>(
                                  value: _idiomaSeleccionado,
                                  items: _idiomas.map<DropdownMenuItem<String>>((lang) {
                                    return DropdownMenuItem<String>(
                                      value: lang['codigo'],
                                      child: Text(lang['nombre']!),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    setState(() => _idiomaSeleccionado = v!);
                                    _guardarConfiguracion('idioma', v);
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text('Tema'),
                                subtitle: Text(_temas.firstWhere((t) => t['codigo'] == _temaSeleccionado)['nombre'] ?? 'Claro'),
                                trailing: DropdownButton<String>(
                                  value: _temaSeleccionado,
                                  items: _temas.map<DropdownMenuItem<String>>((tema) {
                                    return DropdownMenuItem<String>(
                                      value: tema['codigo'],
                                      child: Text('${tema['icono']} ${tema['nombre']}'),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    setState(() => _temaSeleccionado = v!);
                                    _guardarConfiguracion('tema', v);
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text('Tamaño de Fuente'),
                                subtitle: Text(_fuentes.firstWhere((f) => f['codigo'] == _tamanoFuente)['nombre'] ?? 'Mediano'),
                                trailing: DropdownButton<String>(
                                  value: _tamanoFuente,
                                  items: _fuentes.map<DropdownMenuItem<String>>((fuente) {
                                    return DropdownMenuItem<String>(
                                      value: fuente['codigo'],
                                      child: Text('${fuente['nombre']} (${fuente['tamano']}px)'),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    setState(() => _tamanoFuente = v!);
                                    _guardarConfiguracion('tamano_fuente', v);
                                  },
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildConfigSection('SEGURIDAD', Icons.security, [
                              SwitchListTile(
                                title: const Text('Autenticación Biométrica'),
                                subtitle: const Text('Usar huella digital o Face ID para iniciar sesión'),
                                value: _autenticacionBiometrica,
                                onChanged: (v) {
                                  setState(() => _autenticacionBiometrica = v);
                                  _guardarConfiguracion('auth_biometrica', v);
                                },
                                activeColor: AppColors.naranja,
                              ),
                              SwitchListTile(
                                title: const Text('Recordar Sesión'),
                                subtitle: const Text('Mantener sesión iniciada al cerrar la app'),
                                value: _recordarSesion,
                                onChanged: (v) {
                                  setState(() => _recordarSesion = v);
                                  _guardarConfiguracion('recordar_sesion', v);
                                },
                                activeColor: AppColors.naranja,
                              ),
                              ListTile(
                                leading: const Icon(Icons.lock, color: AppColors.naranja),
                                title: const Text('Cambiar Contraseña'),
                                subtitle: const Text('Actualizar tu contraseña'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: _cambiarContrasena,
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildConfigSection('DATOS Y ALMACENAMIENTO', Icons.storage, [
                              ListTile(
                                leading: const Icon(Icons.backup, color: AppColors.naranja),
                                title: const Text('Exportar Datos'),
                                subtitle: const Text('Exportar tus datos personales'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: _exportarDatos,
                              ),
                              ListTile(
                                leading: const Icon(Icons.cleaning_services, color: Colors.orange),
                                title: const Text('Limpiar Caché'),
                                subtitle: const Text('Eliminar datos temporales'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: _limpiarCache,
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildConfigSection('INFORMACIÓN', Icons.info, [
                              ListTile(
                                leading: const Icon(Icons.info_outline, color: AppColors.naranja),
                                title: const Text('Versión de la App'),
                                subtitle: const Text('1.0.0'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => _mostrarInformacion(),
                              ),
                              ListTile(
                                leading: const Icon(Icons.description, color: AppColors.naranja),
                                title: const Text('Términos y Condiciones'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => _mostrarTerminos(context),
                              ),
                              ListTile(
                                leading: const Icon(Icons.privacy_tip, color: AppColors.naranja),
                                title: const Text('Política de Privacidad'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => _mostrarPrivacidad(context),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            Card(
                              color: Colors.red.withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: const Icon(Icons.logout, color: Colors.red),
                                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                subtitle: const Text('Salir de la aplicación', style: TextStyle(color: Colors.red)),
                                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
                                onTap: _cerrarSesion,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
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
        ),
      ),
    );
  }

  Widget _buildPerfilUsuario() {
    final usuario = AutenticacionService.usuarioActual;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.naranja.withOpacity(0.2),
              child: Text(
                usuario?.nombre[0].toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 30, color: AppColors.naranja),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario?.nombre ?? 'Usuario',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario?.email ?? 'usuario@email.com',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.naranja.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      usuario?.role.displayName ?? 'Usuario',
                      style: const TextStyle(fontSize: 12, color: AppColors.naranja),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.naranja),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection(String titulo, IconData icono, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icono, color: AppColors.naranja, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.naranja),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  void _mostrarInformacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_basketball, size: 64, color: AppColors.naranja),
            const SizedBox(height: 16),
            const Text('Federación de Baloncesto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Versión 1.0.0'),
            const SizedBox(height: 8),
            const Text('© 2024 Todos los derechos reservados'),
            const SizedBox(height: 16),
            const Text('Desarrollado por:', style: TextStyle(fontSize: 12)),
            const Text('TFG App', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _mostrarTerminos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: const SingleChildScrollView(
          child: Text(
            'TÉRMINOS Y CONDICIONES DE USO\n\n'
            '1. Aceptación de los términos\n'
            'Al utilizar esta aplicación, usted acepta cumplir con estos términos y condiciones.\n\n'
            '2. Uso de la aplicación\n'
            'La aplicación está destinada exclusivamente para uso personal y no comercial.\n\n'
            '3. Privacidad de datos\n'
            'Sus datos personales serán tratados de acuerdo con nuestra política de privacidad.\n\n'
            '4. Responsabilidad\n'
            'No nos hacemos responsables por el mal uso de la aplicación.\n\n'
            '5. Modificaciones\n'
            'Nos reservamos el derecho de modificar estos términos en cualquier momento.\n\n'
            'Fecha de última actualización: 01/01/2024',
            style: TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _mostrarPrivacidad(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'POLÍTICA DE PRIVACIDAD\n\n'
            '1. Recopilación de datos\n'
            'Recopilamos información personal como nombre, email y datos de perfil.\n\n'
            '2. Uso de datos\n'
            'Utilizamos sus datos para proporcionar los servicios de la aplicación.\n\n'
            '3. Protección de datos\n'
            'Implementamos medidas de seguridad para proteger su información.\n\n'
            '4. Compartir datos\n'
            'No compartimos sus datos personales con terceros sin su consentimiento.\n\n'
            '5. Sus derechos\n'
            'Usted tiene derecho a acceder, corregir o eliminar sus datos personales.\n\n'
            'Contacto: privacidad@federacion.com',
            style: TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}