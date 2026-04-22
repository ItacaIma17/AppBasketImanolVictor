// lib/screens/Admin/GestionUsuariosPage.dart
import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

class GestionUsuariosPage extends StatefulWidget {
  const GestionUsuariosPage({super.key});

  @override
  State<GestionUsuariosPage> createState() => _GestionUsuariosPageState();
}

class _GestionUsuariosPageState extends State<GestionUsuariosPage> {
  final List<Map<String, dynamic>> _usuarios = [
    {'id': 1, 'nombre': 'Juan Pérez', 'email': 'juan@test.com', 'rol': 'Jugador', 'verificado': true},
    {'id': 2, 'nombre': 'María García', 'email': 'maria@test.com', 'rol': 'Entrenador', 'verificado': true},
    {'id': 3, 'nombre': 'Carlos López', 'email': 'carlos@test.com', 'rol': 'Aficionado', 'verificado': false},
    {'id': 4, 'nombre': 'Ana Martínez', 'email': 'ana@test.com', 'rol': 'Árbitro', 'verificado': true},
  ];

  String _searchQuery = '';
  String _filtroRol = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Usuarios',
            style: TextStyle(
              color: AppColors.blanco,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Barra de búsqueda y filtros
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: AppColors.blanco),
                  decoration: InputDecoration(
                    hintText: 'Buscar usuarios...',
                    hintStyle: const TextStyle(color: AppColors.blancoOpacidad70),
                    prefixIcon: const Icon(Icons.search, color: AppColors.blanco),
                    filled: true,
                    fillColor: AppColors.blanco.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.blanco.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _filtroRol,
                  dropdownColor: AppColors.negro,
                  underline: const SizedBox(),
                  items: ['Todos', 'Jugador', 'Entrenador', 'Árbitro', 'Aficionado']
                      .map((rol) => DropdownMenuItem(
                    value: rol,
                    child: Text(rol, style: const TextStyle(color: AppColors.blanco)),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _filtroRol = value!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tabla de usuarios
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blanco,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _usuarios.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final user = _usuarios[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRolColor(user['rol']),
                      child: Text(user['nombre'][0], style: const TextStyle(color: AppColors.blanco)),
                    ),
                    title: Text(user['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!user['verificado'])
                          const Chip(
                            label: Text('No verificado', style: TextStyle(fontSize: 10)),
                            backgroundColor: Colors.orange,
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.naranja),
                          onPressed: () => _editarUsuario(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.block, color: Colors.red),
                          onPressed: () => _bloquearUsuario(user),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol) {
      case 'Jugador': return Colors.green;
      case 'Entrenador': return Colors.orange;
      case 'Árbitro': return Colors.purple;
      default: return Colors.blue;
    }
  }

  void _editarUsuario(Map<String, dynamic> user) {
    // TODO: Implementar edición de usuario
    print('Editar usuario: ${user['nombre']}');
  }

  void _bloquearUsuario(Map<String, dynamic> user) {
    // TODO: Implementar bloqueo de usuario
    print('Bloquear usuario: ${user['nombre']}');
  }
}