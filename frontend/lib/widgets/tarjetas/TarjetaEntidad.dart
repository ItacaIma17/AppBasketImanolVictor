import 'package:flutter/material.dart';
import 'package:tfg_appfede/config/common/resources/colores.dart';

enum TipoEntidad { equipo, jugador, liga }

class TarjetaChip {
  final String texto;
  final IconData? icono;
  const TarjetaChip(this.texto, {this.icono});
}

class TarjetaInfo {
  final IconData icono;
  final String texto;
  const TarjetaInfo({required this.icono, required this.texto});
}

class TarjetaEntidad extends StatelessWidget {
  final TipoEntidad tipo;
  final String titulo;
  final String? subtitulo;
  final String? badge;
  final List<TarjetaChip> chips;
  final List<TarjetaInfo> infos;
  final IconData? iconoOverride;
  final VoidCallback onTap;

  const TarjetaEntidad({
    super.key,
    required this.tipo,
    required this.titulo,
    required this.onTap,
    this.subtitulo,
    this.badge,
    this.chips = const [],
    this.infos = const [],
    this.iconoOverride,
  });

  Color get _acento {
    switch (tipo) {
      case TipoEntidad.equipo:  return AppColors.rojoAragon;
      case TipoEntidad.jugador: return AppColors.naranja;
      case TipoEntidad.liga:    return AppColors.amarilloAragon;
    }
  }

  Gradient get _gradienteAvatar {
    switch (tipo) {
      case TipoEntidad.equipo:
        return const LinearGradient(
          colors: [AppColors.rojoAragon, AppColors.naranja],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        );
      case TipoEntidad.jugador:
        return const LinearGradient(
          colors: [AppColors.naranja, AppColors.amarilloAragon],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        );
      case TipoEntidad.liga:
        return const LinearGradient(
          colors: [AppColors.amarilloAragon, AppColors.naranja],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        );
    }
  }

  IconData get _iconoTipo {
    if (iconoOverride != null) return iconoOverride!;
    switch (tipo) {
      case TipoEntidad.equipo:  return Icons.shield;
      case TipoEntidad.jugador: return Icons.person;
      case TipoEntidad.liga:    return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blanco,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _acento.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    Container(width: 6, color: _acento),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            _buildAvatar(),
                            const SizedBox(width: 14),
                            Expanded(child: _buildContenido()),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right,
                                color: _acento, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: _gradienteAvatar,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _acento.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(_iconoTipo, color: AppColors.blanco, size: 30),
    );
  }

  Widget _buildContenido() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.negro,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _acento,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (subtitulo != null && subtitulo!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitulo!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (infos.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: infos
                .map((i) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(i.icono, size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 3),
                        Text(
                          i.texto,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ],
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: chips.map(_buildChip).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(TarjetaChip c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _acento.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _acento.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (c.icono != null) ...[
            Icon(c.icono, size: 12, color: _acento),
            const SizedBox(width: 4),
          ],
          Text(
            c.texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _acento,
            ),
          ),
        ],
      ),
    );
  }
}

