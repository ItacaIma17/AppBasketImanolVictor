import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';
import 'package:tfg_appfede/services/autenticacion_service.dart';
import 'package:tfg_appfede/models/role.dart';
import '../../models/DTOS/Admin/RegistroAdminDTO.dart';
import '../../models/DTOS/Registro/RegistroArbitroDTO.dart';
import '../../models/DTOS/Registro/RegistroEntrenadorDTO.dart';
import '../../models/DTOS/Registro/RegistroJugadorDTO.dart';
import '../../models/DTOS/Registro/RegistroUsuarioDTO.dart';
import '../../models/DTOS/Registro/registroBaseDTO.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<Registro> {
  // Controladores para los campos del formulario
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController apellidosCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController edadCtrl = TextEditingController();
  final TextEditingController licenciaCtrl = TextEditingController();
  final TextEditingController codigoEntrenadorCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();
  final TextEditingController posicionCtrl = TextEditingController();
  final TextEditingController adminKeyCtrl = TextEditingController();

  // Variables de estado
  bool mostrarPassword = false;
  bool mostrarConfirmPassword = false;
  bool aceptaTerminos = false;
  bool isLoading = false;
  bool _emailEnUso = false;

  // Focus nodes para navegación por teclado
  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _apellidosFocus = FocusNode();
  final FocusNode _edadFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _licenciaFocus = FocusNode();
  final FocusNode _codigoEntrenadorFocus = FocusNode();
  final FocusNode _adminKeyFocus = FocusNode(); // NUEVO para admin
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _posicionFocus = FocusNode();

  // Tipo de usuario seleccionado
  String tipoUsuario = 'Aficionado';
  final List<String> tiposUsuario = [
    'Aficionado',
    'Jugador',
    'Entrenador',
    'Árbitro',
    'Administrador',
  ];

  @override
  void dispose() {
    nombreCtrl.dispose();
    apellidosCtrl.dispose();
    usernameCtrl.dispose();
    edadCtrl.dispose();
    licenciaCtrl.dispose();
    codigoEntrenadorCtrl.dispose();
    adminKeyCtrl.dispose(); // NUEVO
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    posicionCtrl.dispose();

    _nombreFocus.dispose();
    _apellidosFocus.dispose();
    _edadFocus.dispose();
    _usernameFocus.dispose();
    _licenciaFocus.dispose();
    _codigoEntrenadorFocus.dispose();
    _adminKeyFocus.dispose(); // NUEVO
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _posicionFocus.dispose();
    super.dispose();
  }

  /// Verificar si el rol requiere número de licencia
  bool get requiereLicencia {
    return tipoUsuario == 'Jugador' || tipoUsuario == 'Árbitro';
  }

  /// Verificar si el rol requiere código de entrenador
  bool get requiereCodigoEntrenador {
    return tipoUsuario == 'Entrenador';
  }

  /// Verificar si el rol requiere clave de administrador
  bool get requiereAdminKey {
    return tipoUsuario == 'Administrador';
  }

  /// Verificar si el rol requiere posición (solo jugadores)
  bool get requierePosicion {
    return tipoUsuario == 'Jugador';
  }

  /// Validar formato de email en tiempo real
  bool get isEmailValid {
    final email = emailCtrl.text;
    return email.isNotEmpty &&
        email.contains('@') &&
        email.contains('.') &&
        email.length >= 5;
  }

  /// Validar fortaleza de contraseña
  bool get isPasswordStrong {
    final password = passCtrl.text;
    return password.length >= 6 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  /// Obtener mensaje de fortaleza de contraseña
  String get passwordStrengthMessage {
    final password = passCtrl.text;
    if (password.isEmpty) return '';
    if (password.length < 6) return '❌ Mínimo 6 caracteres';
    if (!password.contains(RegExp(r'[A-Z]'))) return '❌ Al menos una mayúscula';
    if (!password.contains(RegExp(r'[0-9]'))) return '❌ Al menos un número';
    return '✅ Contraseña segura';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.gradienteAragon,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botón atrás
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.blanco),
                      onPressed: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 20),

                    // Logo y título
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradienteNaranjaAmarillo,
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.asset(
                                'assets/images/LogoFAB.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.sports_basketball,
                                      size: 60,
                                      color: AppColors.blanco,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'CREAR CUENTA',
                            style: TextStyle(
                              color: AppColors.blanco,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // SELECTOR DE ROL
                    _buildTipoUsuarioSelector(),

                    const SizedBox(height: 24),

                    // Indicador de progreso del formulario
                    _buildProgressIndicator(),

                    const SizedBox(height: 16),

                    // Campos del formulario
                    _buildTextField(
                      controller: nombreCtrl,
                      label: 'Nombre',
                      icon: Icons.person,
                      focusNode: _nombreFocus,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _nombreFocus.nextFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nombre requerido';
                        if (value.length < 2) return 'Mínimo 2 caracteres';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: apellidosCtrl,
                      label: 'Apellidos',
                      icon: Icons.person_outline,
                      focusNode: _apellidosFocus,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _apellidosFocus.nextFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Apellidos requeridos';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: edadCtrl,
                      label: 'Edad',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                      focusNode: _edadFocus,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _edadFocus.nextFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Edad requerida';
                        final edad = int.tryParse(value);
                        if (edad == null) return 'Edad inválida';
                        if (edad < 13) return 'Debes tener al menos 13 años';
                        if (edad > 120) return 'Edad inválida';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: usernameCtrl,
                      label: 'Nombre de usuario',
                      icon: Icons.alternate_email,
                      focusNode: _usernameFocus,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _usernameFocus.nextFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Usuario requerido';
                        if (value.length < 3) return 'Mínimo 3 caracteres';
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                          return 'Solo letras, números y _';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // CAMPO DE LICENCIA PARA JUGADORES Y ÁRBITROS
                    if (requiereLicencia) ...[
                      _buildTextField(
                        controller: licenciaCtrl,
                        label: tipoUsuario == 'Jugador'
                            ? 'Número de Licencia de Jugador'
                            : 'Número de Licencia Arbitral',
                        icon: Icons.badge,
                        keyboardType: TextInputType.number,
                        focusNode: _licenciaFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _licenciaFocus.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Licencia requerida';
                          if (value.length < 5) return 'Licencia inválida';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // CAMPO DE CÓDIGO DE ENTRENADOR
                    if (requiereCodigoEntrenador) ...[
                      _buildTextField(
                        controller: codigoEntrenadorCtrl,
                        label: 'Código de Entrenador',
                        icon: Icons.vpn_key,
                        hintText: 'Ej: ENT-123456',
                        focusNode: _codigoEntrenadorFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _codigoEntrenadorFocus.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El código de entrenador es obligatorio';
                          }
                          if (!value.startsWith('ENT-')) {
                            return 'Formato inválido. Debe comenzar con ENT-';
                          }
                          if (value.length < 8) {
                            return 'Código inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // CAMPO DE CLAVE DE ADMINISTRADOR (NUEVO)
                    if (requiereAdminKey) ...[
                      _buildTextField(
                        controller: adminKeyCtrl,
                        label: 'Clave de Administrador',
                        icon: Icons.admin_panel_settings,
                        hintText: 'Ingresa la clave secreta de administrador',
                        obscureText: true,
                        focusNode: _adminKeyFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _adminKeyFocus.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La clave de administrador es obligatoria';
                          }
                          if (value.length < 6) {
                            return 'Clave inválida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Campo de posición para jugadores
                    if (requierePosicion) ...[
                      _buildTextField(
                        controller: posicionCtrl,
                        label: 'Posición',
                        icon: Icons.sports_soccer,
                        focusNode: _posicionFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _posicionFocus.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Posición requerida';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Campo de email con validación en tiempo real
                    _buildEmailField(),

                    const SizedBox(height: 16),

                    // Campo de contraseña con indicador de fortaleza
                    _buildPasswordField(),

                    const SizedBox(height: 16),

                    // Confirmar contraseña
                    _buildConfirmPasswordField(),

                    const SizedBox(height: 16),

                    // Checkbox de términos y condiciones
                    _buildTermsAndConditions(),

                    const SizedBox(height: 24),

                    // Botón de registro
                    _buildRegisterButton(),

                    const SizedBox(height: 16),

                    // Divisor
                    const Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.blancoOpacidad54)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'O',
                            style: TextStyle(color: AppColors.blanco),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.blancoOpacidad54)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Botones de redes sociales
                    _socialButton(
                      text: 'Continuar con Google',
                      icon: Icons.g_mobiledata,
                      onPressed: _handleGoogleSignIn,
                    ),

                    const SizedBox(height: 12),

                    _socialButton(
                      text: 'Continuar con Facebook',
                      icon: Icons.facebook,
                      onPressed: _handleFacebookSignIn,
                    ),

                    const SizedBox(height: 24),

                    // Enlace a iniciar sesión
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '¿Ya tienes cuenta? INICIAR SESIÓN',
                          style: TextStyle(
                            color: AppColors.blanco,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Overlay de carga
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.naranja),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Creando cuenta...',
                          style: TextStyle(color: AppColors.blanco),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Indicador de progreso del formulario
  Widget _buildProgressIndicator() {
    int camposCompletados = 0;
    int totalCampos = 5 +
        (requiereLicencia ? 1 : 0) +
        (requiereCodigoEntrenador ? 1 : 0) +
        (requiereAdminKey ? 1 : 0) +
        (requierePosicion ? 1 : 0);

    if (nombreCtrl.text.isNotEmpty) camposCompletados++;
    if (apellidosCtrl.text.isNotEmpty) camposCompletados++;
    if (usernameCtrl.text.isNotEmpty) camposCompletados++;
    if (emailCtrl.text.isNotEmpty && isEmailValid) camposCompletados++;
    if (passCtrl.text.isNotEmpty && confirmPassCtrl.text.isNotEmpty && passCtrl.text == confirmPassCtrl.text) camposCompletados++;
    if (requiereLicencia && licenciaCtrl.text.isNotEmpty) camposCompletados++;
    if (requiereCodigoEntrenador && codigoEntrenadorCtrl.text.isNotEmpty) camposCompletados++;
    if (requiereAdminKey && adminKeyCtrl.text.isNotEmpty) camposCompletados++;
    if (requierePosicion && posicionCtrl.text.isNotEmpty) camposCompletados++;

    final progress = totalCampos > 0 ? camposCompletados / totalCampos : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progreso del registro',
              style: TextStyle(color: AppColors.blanco, fontSize: 12),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(color: AppColors.blanco, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.blancoOpacidad70,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.naranja),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  /// Campo de email con validación en tiempo real
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: emailCtrl,
          label: 'Correo Electrónico',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          focusNode: _emailFocus,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            setState(() {
              _emailEnUso = false;
            });
          },
          onSubmitted: (_) => _emailFocus.nextFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Email requerido';
            if (!value.contains('@')) return 'Email inválido';
            if (!value.contains('.')) return 'Email inválido';
            return null;
          },
        ),
        if (_emailEnUso)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Este email ya está registrado',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Campo de contraseña con indicador de fortaleza
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: passCtrl,
          label: 'Contraseña',
          icon: Icons.lock,
          obscureText: !mostrarPassword,
          focusNode: _passwordFocus,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: (_) => _passwordFocus.nextFocus(),
          suffixIcon: IconButton(
            icon: Icon(
              mostrarPassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.blancoOpacidad70,
            ),
            onPressed: () {
              setState(() => mostrarPassword = !mostrarPassword);
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Contraseña requerida';
            if (value.length < 6) return 'Mínimo 6 caracteres';
            if (!value.contains(RegExp(r'[A-Z]'))) return 'Al menos una mayúscula';
            if (!value.contains(RegExp(r'[0-9]'))) return 'Al menos un número';
            return null;
          },
        ),
        if (passCtrl.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              passwordStrengthMessage,
              style: TextStyle(
                color: isPasswordStrong ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  /// Campo de confirmación de contraseña
  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      controller: confirmPassCtrl,
      label: 'Repite la Contraseña',
      icon: Icons.lock_outline,
      obscureText: !mostrarConfirmPassword,
      focusNode: _confirmPasswordFocus,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        setState(() {});
      },
      onSubmitted: (_) => _handleRegistro(),
      suffixIcon: IconButton(
        icon: Icon(
          mostrarConfirmPassword ? Icons.visibility : Icons.visibility_off,
          color: AppColors.blancoOpacidad70,
        ),
        onPressed: () {
          setState(() => mostrarConfirmPassword = !mostrarConfirmPassword);
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Confirmar contraseña';
        if (value != passCtrl.text) return 'Las contraseñas no coinciden';
        return null;
      },
    );
  }

  /// Checkbox de términos y condiciones mejorado
  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: aceptaTerminos,
          onChanged: (value) {
            setState(() => aceptaTerminos = value ?? false);
          },
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.naranja;
            }
            return AppColors.blanco;
          }),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _showTermsAndConditions,
            child: const Text(
              'Acepto los Términos y Condiciones',
              style: TextStyle(
                color: AppColors.blanco,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Botón de registro con validación de formulario
  Widget _buildRegisterButton() {
    final isFormValid = aceptaTerminos &&
        nombreCtrl.text.isNotEmpty &&
        apellidosCtrl.text.isNotEmpty &&
        usernameCtrl.text.isNotEmpty &&
        edadCtrl.text.isNotEmpty &&
        emailCtrl.text.isNotEmpty &&
        isEmailValid &&
        passCtrl.text.isNotEmpty &&
        confirmPassCtrl.text.isNotEmpty &&
        passCtrl.text == confirmPassCtrl.text &&
        isPasswordStrong &&
        (!requiereLicencia || licenciaCtrl.text.isNotEmpty) &&
        (!requiereCodigoEntrenador || codigoEntrenadorCtrl.text.isNotEmpty) &&
        (!requiereAdminKey || adminKeyCtrl.text.isNotEmpty) &&
        (!requierePosicion || posicionCtrl.text.isNotEmpty);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.naranja,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isFormValid && !isLoading ? _handleRegistro : null,
        child: const Text(
          'REGISTRARSE',
          style: TextStyle(
            color: AppColors.blanco,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Mostrar términos y condiciones
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: const SingleChildScrollView(
          child: Text(
            'Términos y condiciones de uso...\n\n'
                '1. Aceptas cumplir con las normas de la FAB.\n'
                '2. Tus datos serán tratados según la ley de protección de datos.\n'
                '3. No compartirás información falsa.\n'
                '4. Serás responsable de tu cuenta.\n\n'
                'Al registrarte, aceptas estos términos.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => aceptaTerminos = true);
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Widget de campo de texto reutilizable mejorado
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.blanco),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.blancoOpacidad70),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.blancoOpacidad54),
        prefixIcon: Icon(icon, color: AppColors.blancoOpacidad70),
        suffixIcon: suffixIcon,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blancoOpacidad54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blanco),
        ),
        errorStyle: const TextStyle(color: Colors.orange),
      ),
    );
  }

  /// Selector de tipo de usuario con menú desplegable
  Widget _buildTipoUsuarioSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge, color: AppColors.naranja, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Selecciona tu rol',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.negro,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppColors.naranja),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _mostrarInfoTipoUsuario,
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: tipoUsuario,
              isExpanded: true,
              dropdownColor: AppColors.blanco,
              style: const TextStyle(
                color: AppColors.negro,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
              items: tiposUsuario.map((String tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Row(
                    children: [
                      Icon(
                        _getIconForRole(tipo),
                        color: AppColors.naranja,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(tipo),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    tipoUsuario = newValue;
                    if (!requiereLicencia) {
                      licenciaCtrl.clear();
                    }
                    if (!requiereCodigoEntrenador) {
                      codigoEntrenadorCtrl.clear();
                    }
                    if (!requiereAdminKey) {
                      adminKeyCtrl.clear();
                    }
                    if (!requierePosicion) {
                      posicionCtrl.clear();
                    }
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Obtener icono según el rol
  IconData _getIconForRole(String role) {
    switch (role) {
      case 'Jugador':
        return Icons.sports_basketball;
      case 'Entrenador':
        return Icons.sports;
      case 'Árbitro':
        return Icons.sports_score;
      case 'Aficionado':
        return Icons.favorite;
      case 'Administrador':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  /// Botón de redes sociales
  Widget _socialButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.blanco),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.blanco),
        label: Text(
          text,
          style: const TextStyle(color: AppColors.blanco),
        ),
      ),
    );
  }

  /// Mostrar información sobre los tipos de usuario
  void _mostrarInfoTipoUsuario() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tipos de Usuario'),
        content: const Text(
          '👑 Administrador: Necesitarás la clave secreta de administrador\n\n'
              '🏀 Jugador: Necesitarás tu número de licencia de jugador y posición\n\n'
              '🏆 Entrenador: Necesitarás un código de entrenador válido (formato ENT-XXXXXX)\n\n'
              '⚖️ Árbitro: Necesitarás tu número de licencia arbitral\n\n'
              '❤️ Aficionado: Acceso como seguidor de equipos (no requiere licencia)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Manejar registro con los DTOs correctos
  /// Manejar registro con los DTOs correctos
  void _handleRegistro() async {
    setState(() => isLoading = true);

    try {
      RegistroBaseDTO registroDTO;
      final rol = _mapRole(tipoUsuario);

      print('📝 Rol seleccionado: $tipoUsuario -> ${rol.value}');

      switch (rol) {
        case Role.ADMIN:
          print('📝 Creando RegistroAdminDTO con adminKey: ${adminKeyCtrl.text}');
          registroDTO = RegistroAdminDTO(
            email: emailCtrl.text,
            username: usernameCtrl.text,
            nombre: nombreCtrl.text,
            apellido: apellidosCtrl.text,
            edad: int.parse(edadCtrl.text),
            password: passCtrl.text,
            adminKey: adminKeyCtrl.text,
          );
          break;

        case Role.ENTRENADOR:
          print('📝 Creando RegisterEntrenadorDTO');
          registroDTO = RegisterEntrenadorDTO(
            email: emailCtrl.text,
            username: usernameCtrl.text,
            nombre: nombreCtrl.text,
            apellido: apellidosCtrl.text,
            edad: int.parse(edadCtrl.text),
            password: passCtrl.text,
            codigoEntrenador: codigoEntrenadorCtrl.text,
          );
          break;

        case Role.JUGADOR:
          print('📝 Creando RegistroJugadorDTO');
          registroDTO = RegistroJugadorDTO(
            email: emailCtrl.text,
            username: usernameCtrl.text,
            nombre: nombreCtrl.text,
            apellido: apellidosCtrl.text,
            edad: int.parse(edadCtrl.text),
            password: passCtrl.text,
            codigoJugador: licenciaCtrl.text,
            posicion: posicionCtrl.text,
          );
          break;

        case Role.ARBITRO:
          print('📝 Creando RegistroArbitroDTO');
          registroDTO = RegistroArbitroDTO(
            email: emailCtrl.text,
            username: usernameCtrl.text,
            nombre: nombreCtrl.text,
            apellido: apellidosCtrl.text,
            edad: int.parse(edadCtrl.text),
            password: passCtrl.text,
            codigoArbitro: licenciaCtrl.text,
          );
          break;

        default:
          print('📝 Creando RegistroUsuarioDTO');
          registroDTO = RegistroUsuarioDTO(
            email: emailCtrl.text,
            username: usernameCtrl.text,
            nombre: nombreCtrl.text,
            apellido: apellidosCtrl.text,
            edad: int.parse(edadCtrl.text),
            password: passCtrl.text,
          );
          break;
      }

      print('📝 Enviando registro con rol: ${registroDTO.rol}');

      final exito = await AutenticacionService.registrarUsuarioConDTO(registroDTO);

      if (exito && mounted) {
        // ✅ SI ES ADMIN, NO MOSTRAR VERIFICACIÓN
        if (rol == Role.ADMIN) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Administrador registrado exitosamente. Ya puedes iniciar sesión.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Volver al login
        } else {
          _showVerificationDialog(); // Solo para no administradores
        }
      }

    } catch (e) {
      print('❌ Error en registro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Mostrar diálogo de verificación de código
  void _showVerificationDialog() {
    final codeController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Verificación de Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  'Hemos enviado un código de verificación a:',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  emailCtrl.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text('Por favor, ingresa el código de 6 dígitos:'),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código de verificación',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                ),
                if (isVerifying)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isVerifying ? null : () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: isVerifying ? null : () async {
                  if (codeController.text.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ingresa el código de 6 dígitos')),
                    );
                    return;
                  }

                  setDialogState(() => isVerifying = true);

                  try {
                    final loginResponse = await AutenticacionService.verificarCodigo(
                      codeController.text,
                      emailCtrl.text,
                    );

                    if (loginResponse != null && mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Cuenta verificada exitosamente!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    setDialogState(() => isVerifying = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Verificar'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Manejar registro con Google
  void _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign In - Próximamente')),
      );
    } catch (e) {
      _mostrarError('Error con Google: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Manejar registro con Facebook
  void _handleFacebookSignIn() async {
    setState(() => isLoading = true);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facebook Sign In - Próximamente')),
      );
    } catch (e) {
      _mostrarError('Error con Facebook: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Mapear string a enum Role
  Role _mapRole(String tipoUsuarioStr) {
    switch (tipoUsuarioStr) {
      case 'Jugador':
        return Role.JUGADOR;
      case 'Entrenador':
        return Role.ENTRENADOR;
      case 'Árbitro':
        return Role.ARBITRO;
      case 'Aficionado':
        return Role.USUARIO;
      case 'Administrador':
        return Role.ADMIN;
      default:
        return Role.USUARIO;
    }
  }

  /// Mostrar mensaje de error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }
}