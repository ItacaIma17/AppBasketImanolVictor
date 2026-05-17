package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Entity.EstadoPartido.EstadoPartido;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.*;
import Presentacion.DTOS.Admin.AdminPanelInfoDTO;
import Presentacion.DTOS.Admin.ComunicadoAdminDTO;
import Presentacion.DTOS.Admin.SancionDTO;
import Presentacion.DTOS.Arbitro.ArbitroResponse;
import Presentacion.DTOS.Arbitro.AsignarArbitroDTO;
import Presentacion.DTOS.Jugador.JugadorResponse;
import Presentacion.DTOS.Partido.RecordatorioPartidoDTO;
import Presentacion.DTOS.Usuarios.UsuarioPerfilDTO;
import jakarta.mail.MessagingException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final JugadorRepository jugadorRepository;
    private final EntrenadorRepository entrenadorRepository;
    private final ArbitroRepository arbitroRepository;
    private final EquipoRepository equipoRepository;
    private final LigaRepository ligaRepository;
    private final PartidoRepository partidoRepository;
    private final EmailService emailService;
    private final NotificacionService notificacionService;

    public AdminPanelInfoDTO obtenerResumen() {
        AdminPanelInfoDTO panel = new AdminPanelInfoDTO();

        panel.setTotalUsuarios((int) userRepository.count());
        panel.setTotalJugadores((int) jugadorRepository.count());
        panel.setTotalEntrenadores((int) entrenadorRepository.count());
        panel.setTotalArbitros((int) arbitroRepository.count());
        panel.setTotalEquipos((int) equipoRepository.count());
        panel.setTotalLigas((int) ligaRepository.count());
        panel.setTotalPartidos((int) partidoRepository.count());
        panel.setUsuariosBloqueados(
                (int) userRepository.countByBloqueado(true));
        panel.setUsuariosPendientesVerificacion(
                (int) userRepository.countByVerificado(false));
        panel.setUltimosRegistros(
                userRepository.findTop5ByOrderByIdDesc()
                        .stream()
                        .map(u -> u.getNombre() + " " + u.getApellido() +
                                " (" + u.getRole().name() + ")")
                        .collect(Collectors.toList()));

        return panel;
    }

    public List<UsuarioPerfilDTO> listarTodosUsuarios() {
        return userRepository.findAll()
                .stream()
                .map(UsuarioPerfilDTO::fromEntity)
                .collect(Collectors.toList());
    }

    public List<UsuarioPerfilDTO> listarUsuariosPorRol(Roles rol) {
        return userRepository.findByRole(rol)
                .stream()
                .map(UsuarioPerfilDTO::fromEntity)
                .collect(Collectors.toList());
    }

    public List<UsuarioPerfilDTO> listarUsuariosPendientes() {
        return userRepository.findByVerificado(false)
                .stream()
                .map(UsuarioPerfilDTO::fromEntity)
                .collect(Collectors.toList());
    }

    public List<UsuarioPerfilDTO> listarUsuariosBloqueados() {
        return userRepository.findByBloqueado(true)
                .stream()
                .map(UsuarioPerfilDTO::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> obtenerEstadisticas() {
        Map<String, Object> stats = new HashMap<>();

        stats.put("totalUsuarios", userRepository.count());
        stats.put("totalEntrenadores", entrenadorRepository.count());
        stats.put("totalJugadores", jugadorRepository.count());
        stats.put("totalArbitros", arbitroRepository.count());
        stats.put("totalEquipos", equipoRepository.count());
        stats.put("totalLigas", ligaRepository.count());
        stats.put("totalPartidos", partidoRepository.count());
        stats.put("usuariosActivos", userRepository.countByBloqueado(false));
        stats.put("partidosHoy", partidoRepository.countPartidosHoy());
        stats.put("partidosFinalizados", partidoRepository.countByEstado("FINALIZADO"));
        stats.put("partidosPendientes", partidoRepository.countByEstado("PROGRAMADO"));

        log.info(" Estadísticas obtenidas: Usuarios={}, Equipos={}, Partidos={}",
                stats.get("totalUsuarios"), stats.get("totalEquipos"), stats.get("totalPartidos"));

        return stats;
    }

    @Transactional
    public List<Map<String, Object>> obtenerActividadReciente() {
        List<Map<String, Object>> actividades = new ArrayList<>();

        userRepository.findTop5ByOrderByIdDesc().forEach(user -> {
            Map<String, Object> actividad = new HashMap<>();
            actividad.put("accion", "Nuevo usuario registrado");
            actividad.put("usuario", user.getUsername());
            actividad.put("rol", user.getRole().toString());
            actividad.put("fecha", user.getId().toString());
            actividad.put("tipo", "usuario");
            actividades.add(actividad);
        });

        partidoRepository.findTop5ByOrderByFechaDesc().forEach(partido -> {
            Map<String, Object> actividad = new HashMap<>();
            actividad.put("accion", "Partido programado");
            actividad.put("usuario", "admin");
            actividad.put("detalle", partido.getEquipoLocal().getNombre() + " vs " + partido.getEquipoVisitante().getNombre());
            actividad.put("fecha", partido.getFecha().toString());
            actividad.put("tipo", "partido");
            actividades.add(actividad);
        });

        return actividades;
    }

    @Transactional
    public void bloquearUsuario(Long id) {
        Usuario usuario = findUsuario(id);
        usuario.setBloqueado(true);
        userRepository.save(usuario);

        try {
            emailService.enviarCuentaBloqueada(
                    usuario.getEmail(), usuario.getNombre());
        } catch (MessagingException e) {
            log.warn("No se pudo enviar email de bloqueo: {}", e.getMessage());
        }

        log.info("Usuario bloqueado: {}", usuario.getUsername());
    }

    @Transactional
    public void desbloquearUsuario(Long id) {
        Usuario usuario = findUsuario(id);
        usuario.setBloqueado(false);
        userRepository.save(usuario);

        try {
            emailService.enviarCuentaDesbloqueada(
                    usuario.getEmail(), usuario.getNombre());
        } catch (MessagingException e) {
            log.warn("No se pudo enviar email de desbloqueo: {}", e.getMessage());
        }

        log.info("Usuario desbloqueado: {}", usuario.getUsername());
    }

    @Transactional
    public void eliminarUsuario(Long id) {
        Usuario usuario = findUsuario(id);
        userRepository.deleteById(id);
        log.info("Usuario eliminado: {}", usuario.getUsername());
    }

    public List<JugadorResponse> listarJugadoresSinEquipo() {
        return jugadorRepository.findByEquipoIsNull()
                .stream().map(this::toJugadorResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public void asignarJugadorAEquipo(Long jugadorId, Long equipoId) {
        Jugador jugador = jugadorRepository.findById(jugadorId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Jugador no encontrado"));
        Equipo equipo = equipoRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Equipo no encontrado"));

        jugador.setEquipo(equipo);
        jugadorRepository.save(jugador);

        try {
            emailService.enviarInscripcionEquipo(
                    jugador.getEmail(),
                    jugador.getNombre(),
                    equipo.getNombre(),
                    equipo.getLiga() != null ?
                            equipo.getLiga().getNombreLiga() : "Liga no asignada");
        } catch (MessagingException e) {
            log.warn("No se pudo enviar email de inscripción: {}", e.getMessage());
        }

        log.info("Jugador {} asignado a equipo {}", jugadorId, equipoId);
    }

    @Transactional
    public void asignarJugadoresMasivo(Long equipoId, List<Long> jugadorIds) {
        Equipo equipo = equipoRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Equipo no encontrado"));

        jugadorIds.forEach(id -> {
            jugadorRepository.findById(id).ifPresent(jugador -> {
                jugador.setEquipo(equipo);
                jugadorRepository.save(jugador);

                try {
                    emailService.enviarInscripcionEquipo(
                            jugador.getEmail(),
                            jugador.getNombre(),
                            equipo.getNombre(),
                            equipo.getLiga() != null ?
                                    equipo.getLiga().getNombreLiga() : "");
                } catch (MessagingException e) {
                    log.warn("Email no enviado a {}", jugador.getEmail());
                }
            });
        });
    }

    @Transactional
    public void asignarEntrenadorAEquipo(Long entrenadorId, Long equipoId) {
        Entrenador entrenador = entrenadorRepository.findById(entrenadorId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Entrenador no encontrado"));
        Equipo equipo = equipoRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Equipo no encontrado"));

        equipo.setEntrenador(entrenador);
        equipoRepository.save(equipo);

        try {
            emailService.enviarAsignacionEquipoEntrenador(
                    entrenador.getEmail(),
                    entrenador.getNombre(),
                    equipo.getNombre());
        } catch (MessagingException e) {
            log.warn("Email no enviado al entrenador: {}", e.getMessage());
        }
    }

    public List<ArbitroResponse> listarTodosArbitros() {
        return arbitroRepository.findAll().stream()
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ArbitroResponse> listarArbitrosDisponibles() {

        List<Arbitro> arbitros = arbitroRepository.findArbitrosSinPartidos();

        return arbitros.stream()
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public void asignarArbitroAPartido(AsignarArbitroDTO dto) {
        Arbitro arbitro = arbitroRepository.findById(dto.getArbitroId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Árbitro no encontrado"));

        Partido partido = partidoRepository.findById(dto.getPartidoId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Partido no encontrado"));

        if (partido.getActaPartido() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Este partido ya tiene un acta finalizada");
        }

        partido.setArbitro(arbitro);
        partidoRepository.save(partido);

        try {
            emailService.enviarAsignacionPartidoArbitro(
                    arbitro.getEmail(),
                    arbitro.getNombre(),
                    partido.getEquipoLocal().getNombre(),
                    partido.getEquipoVisitante().getNombre(),
                    partido.getFecha(),
                    partido.getPabellon());
        } catch (MessagingException e) {
            log.warn("Email no enviado al árbitro: {}", e.getMessage());
        }

        notificacionService.notificarSeguidoresEquipos(partido,
                "Árbitro designado - " + partido.getEquipoLocal().getNombre() + " vs " + partido.getEquipoVisitante().getNombre(),
                "Se ha designado árbitro para el partido de tu equipo favorito:<br><br>" +
                "<strong>" + partido.getEquipoLocal().getNombre() + "</strong> vs <strong>" +
                partido.getEquipoVisitante().getNombre() + "</strong><br><br>" +
                " <strong>Árbitro:</strong> " + arbitro.getNombre() + " " + arbitro.getApellidos() + "<br>" +
                " <strong>Fecha:</strong> " + (partido.getFecha() != null ? partido.getFecha().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "por confirmar") + "<br>" +
                " <strong>Pabellón:</strong> " + (partido.getPabellon() != null ? partido.getPabellon() : "por confirmar"));

        log.info("Árbitro {} asignado al partido {}", arbitro.getNombre(), partido.getId());
    }

    @Transactional
    public void desasignarArbitro(Long partidoId) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Partido no encontrado"));

        if (partido.getActaPartido() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "No se puede desasignar el árbitro porque el partido ya tiene acta");
        }

        partido.setArbitro(null);
        partidoRepository.save(partido);
        log.info("Árbitro desasignado del partido {}", partidoId);
    }

    @Transactional
    public Partido crearPartido(Partido partido) {

        if (partido.getEquipoLocal() == null || partido.getEquipoVisitante() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Los equipos son obligatorios");
        }

        if (partido.getEquipoLocal().getId().equals(partido.getEquipoVisitante().getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Un equipo no puede jugar contra sí mismo");
        }

        partido.setEstado(EstadoPartido.PROGRAMADO.name());
        return partidoRepository.save(partido);
    }

    @Transactional
    public Partido actualizarPartido(Long id, Partido partidoActualizado) {
        Partido partido = partidoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

        partido.setFecha(partidoActualizado.getFecha());
        partido.setPabellon(partidoActualizado.getPabellon());
        partido.setUbicacion(partidoActualizado.getUbicacion());
        partido.setLiga(partidoActualizado.getLiga());

        return partidoRepository.save(partido);
    }

    @Transactional
    public void eliminarPartido(Long id) {
        Partido partido = partidoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));
        partidoRepository.delete(partido);
        log.info("Partido eliminado: {}", id);
    }

    @Transactional
    public void enviarRecordatorioPartido(Long partidoId) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Partido no encontrado"));

        RecordatorioPartidoDTO dtoBase = new RecordatorioPartidoDTO();
        dtoBase.setNombreRival(null);
        dtoBase.setFecha(partido.getFecha());
        dtoBase.setPabellon(partido.getPabellon());
        dtoBase.setDireccionPabellon(partido.getUbicacion());

        int emailsEnviados = 0;

        if (partido.getArbitro() != null) {
            RecordatorioPartidoDTO dtoArbitro = new RecordatorioPartidoDTO();
            dtoArbitro.setSendto(partido.getArbitro().getEmail());
            dtoArbitro.setNombreUsuario(partido.getArbitro().getNombre());
            dtoArbitro.setNombreRival(partido.getEquipoLocal().getNombre() + " vs " +
                    partido.getEquipoVisitante().getNombre());
            dtoArbitro.setFecha(partido.getFecha());
            dtoArbitro.setPabellon(partido.getPabellon());
            dtoArbitro.setDireccionPabellon(partido.getUbicacion());

            try {
                emailService.enviarRecordatorioPartido(dtoArbitro);
                emailsEnviados++;
                log.info("Recordatorio enviado al árbitro: {}", partido.getArbitro().getEmail());
            } catch (MessagingException e) {
                log.warn("No se pudo enviar recordatorio al árbitro: {}", e.getMessage());
            }
        }

        emailsEnviados += enviarRecordatorioAEquipo(partido, partido.getEquipoLocal(), true);

        emailsEnviados += enviarRecordatorioAEquipo(partido, partido.getEquipoVisitante(), false);

        log.info("Recordatorio de partido {} enviado a {} destinatarios", partidoId, emailsEnviados);
    }

    private int enviarRecordatorioAEquipo(Partido partido, Equipo equipo, boolean esLocal) {
        int contador = 0;
        String nombreRival = esLocal ?
                partido.getEquipoVisitante().getNombre() :
                partido.getEquipoLocal().getNombre();

        if (equipo.getEntrenador() != null) {
            RecordatorioPartidoDTO dtoEntrenador = new RecordatorioPartidoDTO();
            dtoEntrenador.setSendto(equipo.getEntrenador().getEmail());
            dtoEntrenador.setNombreUsuario(equipo.getEntrenador().getNombre());
            dtoEntrenador.setNombreRival(nombreRival);
            dtoEntrenador.setFecha(partido.getFecha());
            dtoEntrenador.setPabellon(partido.getPabellon());
            dtoEntrenador.setDireccionPabellon(partido.getUbicacion());

            try {
                emailService.enviarRecordatorioPartido(dtoEntrenador);
                contador++;
                log.info("Recordatorio enviado al entrenador: {}", equipo.getEntrenador().getEmail());
            } catch (MessagingException e) {
                log.warn("No se pudo enviar recordatorio al entrenador: {}", e.getMessage());
            }
        }

        if (equipo.getJugadores() != null) {
            for (Jugador jugador : equipo.getJugadores()) {
                RecordatorioPartidoDTO dtoJugador = new RecordatorioPartidoDTO();
                dtoJugador.setSendto(jugador.getEmail());
                dtoJugador.setNombreUsuario(jugador.getNombre());
                dtoJugador.setNombreRival(nombreRival);
                dtoJugador.setFecha(partido.getFecha());
                dtoJugador.setPabellon(partido.getPabellon());
                dtoJugador.setDireccionPabellon(partido.getUbicacion());

                try {
                    emailService.enviarRecordatorioPartido(dtoJugador);
                    contador++;
                } catch (MessagingException e) {
                    log.warn("No se pudo enviar recordatorio al jugador {}: {}",
                            jugador.getEmail(), e.getMessage());
                }
            }
        }

        return contador;
    }

    public void enviarRecordatoriosPartidosDelDia(LocalDateTime fechaInicio, LocalDateTime fechaFin) {
        List<Partido> partidos = partidoRepository.findByFechaBetween(fechaInicio, fechaFin);

        for (Partido partido : partidos) {
            enviarRecordatorioPartido(partido.getId());
        }

        log.info("Enviados recordatorios para {} partidos del día {}", partidos.size(), fechaInicio, fechaFin);
    }

    public void enviarRecordatorioArbitro(Long partidoId) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Partido no encontrado"));

        if (partido.getArbitro() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "El partido no tiene árbitro asignado");
        }

        RecordatorioPartidoDTO dto = new RecordatorioPartidoDTO();
        dto.setSendto(partido.getArbitro().getEmail());
        dto.setNombreUsuario(partido.getArbitro().getNombre());
        dto.setNombreRival(partido.getEquipoLocal().getNombre() + " vs " +
                partido.getEquipoVisitante().getNombre());
        dto.setFecha(partido.getFecha());
        dto.setPabellon(partido.getPabellon());
        dto.setDireccionPabellon(partido.getUbicacion());

        try {
            emailService.enviarRecordatorioPartido(dto);
            log.info("Recordatorio enviado al árbitro del partido {}", partidoId);
        } catch (MessagingException e) {
            log.error("Error al enviar recordatorio al árbitro: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Error al enviar el email");
        }
    }

    public void enviarRecordatorioAEquipo(Long partidoId, Long equipoId) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Partido no encontrado"));
        Equipo equipo = equipoRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Equipo no encontrado"));

        if (!partido.participaEquipo(equipo)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "El equipo no participa en este partido");
        }

        boolean esLocal = partido.getEquipoLocal().getId().equals(equipoId);
        int enviados = enviarRecordatorioAEquipo(partido, equipo, esLocal);

        log.info("Recordatorio enviado a {} miembros del equipo {}", enviados, equipo.getNombre());
    }

    @Transactional
    public void sancionarJugador(SancionDTO dto) {
        Jugador jugador = jugadorRepository.findById(dto.getJugadorId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Jugador no encontrado"));

        try {
            emailService.enviarSancion(
                    jugador.getEmail(),
                    jugador.getNombre(),
                    dto.getPartidosSancion(),
                    dto.getMotivo());

            if (jugador.getEquipo() != null &&
                    jugador.getEquipo().getEntrenador() != null) {
                emailService.enviarNotificacionSancionEntrenador(
                        jugador.getEquipo().getEntrenador().getEmail(),
                        jugador.getEquipo().getEntrenador().getNombre(),
                        jugador.getNombre() + " " + jugador.getApellido(),
                        dto.getPartidosSancion(),
                        dto.getMotivo());
            }
        } catch (MessagingException e) {
            log.warn("Email de sanción no enviado: {}", e.getMessage());
        }

        log.info("Jugador {} sancionado {} partidos", jugador.getId(),
                dto.getPartidosSancion());
    }

    public void enviarComunicado(ComunicadoAdminDTO dto) {

        if (dto.getDestinatarios() != null && !dto.getDestinatarios().isEmpty()) {
            dto.getDestinatarios().forEach(email -> {
                try {
                    emailService.enviarComunicado(
                            email,
                            dto.getAsunto(),
                            dto.getMensaje()
                    );
                    log.info("Comunicado enviado a: {}", email);
                } catch (MessagingException e) {
                    log.warn("No se pudo enviar comunicado a {}: {}", email, e.getMessage());
                }
            });
            return;
        }

        List<Usuario> destinatarios;

        if (dto.getRolDestino() == null || dto.getRolDestino().equalsIgnoreCase("TODOS")) {

            destinatarios = userRepository.findAll();
            log.info("Preparando envío masivo a TODOS los usuarios");
        } else {

            try {
                Roles rol = Roles.valueOf(dto.getRolDestino().toUpperCase());
                destinatarios = userRepository.findByRole(rol);
                log.info("Preparando envío a usuarios con rol: {}", rol);
            } catch (IllegalArgumentException e) {
                log.error("Rol inválido: {}", dto.getRolDestino());
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Rol destino no válido: " + dto.getRolDestino()
                );
            }
        }

        int exitosos = 0;
        int fallidos = 0;

        for (Usuario usuario : destinatarios) {
            try {
                emailService.enviarComunicado(
                        usuario.getEmail(),
                        dto.getAsunto(),
                        dto.getMensaje()
                );
                exitosos++;
                log.debug("Comunicado enviado a: {}", usuario.getEmail());
            } catch (MessagingException e) {
                fallidos++;
                log.warn("No se pudo enviar comunicado a {}: {}", usuario.getEmail(), e.getMessage());
            }
        }

        log.info("Comunicado enviado - Exitosos: {}, Fallidos: {}, Total: {}",
                exitosos, fallidos, destinatarios.size());
    }

    private Usuario findUsuario(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Usuario no encontrado"));
    }

    private JugadorResponse toJugadorResponse(Jugador j) {
        JugadorResponse r = new JugadorResponse();
        r.setId(j.getId());
        r.setNombre(j.getNombre());
        r.setApellido(j.getApellido());
        r.setEmail(j.getEmail());
        r.setPosicion(j.getPosicion());
        r.setDorsal(j.getDorsal());
        return r;
    }
}
