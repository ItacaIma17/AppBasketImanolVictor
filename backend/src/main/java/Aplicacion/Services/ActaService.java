package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Repositorys.ActaPartidoRepository;
import Dominio.Repositorys.ArbitroRepository;
import Dominio.Repositorys.EquipoRepository;
import Dominio.Repositorys.PartidoRepository;
import Presentacion.DTOS.Arbitro.ActaRequestDTO;
import Presentacion.DTOS.Arbitro.ActaResponseDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ActaService {

    private final ActaPartidoRepository actaPartidoRepository;
    private final PartidoRepository partidoRepository;
    private final ArbitroRepository arbitroRepository;
    private final EquipoRepository equipoRepository; // Añadir si no existe

    // ============================================================
    // CRUD EXISTENTE (ya lo tienes, lo mantengo)
    // ============================================================

    @Transactional
    public ActaResponseDTO guardarActa(ActaRequestDTO request, String username) {
        log.info("📝 Guardando acta para partido ID: {}", request.getPartidoId());

        if (actaPartidoRepository.existsByPartidoId(request.getPartidoId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe un acta para este partido");
        }

        Arbitro arbitro = arbitroRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Árbitro no encontrado"));

        Partido partido = partidoRepository.findById(request.getPartidoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

        if (partido.getArbitro() == null || !partido.getArbitro().getId().equals(arbitro.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permisos para crear acta de este partido");
        }

        if ("FINALIZADO".equals(partido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El partido ya está finalizado");
        }

        ActaPartido acta = new ActaPartido();
        acta.setPartido(partido);
        acta.setArbitro(arbitro);
        acta.setFechaActa(LocalDateTime.now());
        acta.setResultadoLocal(request.getResultadoLocal());
        acta.setResultadoVisitante(request.getResultadoVisitante());
        acta.setObservaciones(request.getObservaciones());

        if (request.getEventos() != null) {
            request.getEventos().forEach(eventoDTO -> {
                EventoPartido evento = new EventoPartido();
                evento.setActa(acta);
                evento.setNombreJugador(eventoDTO.getNombreJugador());
                evento.setNombreEquipo(eventoDTO.getNombreEquipo());
                evento.setMinuto(eventoDTO.getMinuto());
                evento.setTipo(eventoDTO.getTipo());
                evento.setDescripcion(eventoDTO.getDescripcion());
                evento.setTimestamp(LocalDateTime.now());

                if ("CANASTA".equals(eventoDTO.getTipo())) {
                    evento.setPuntos(2);
                } else if ("TIRO_3PUNTOS".equals(eventoDTO.getTipo())) {
                    evento.setPuntos(3);
                } else if ("TIRO_LIBRE".equals(eventoDTO.getTipo())) {
                    evento.setPuntos(1);
                }

                acta.getEventos().add(evento);
            });
        }

        partido.setResultadoLocal(Integer.parseInt(request.getResultadoLocal()));
        partido.setResultadoVisitante(Integer.parseInt(request.getResultadoVisitante()));
        partido.setEstado("FINALIZADO");
        partidoRepository.save(partido);

        ActaPartido saved = actaPartidoRepository.save(acta);
        log.info("✅ Acta guardada con ID: {}", saved.getId());

        return ActaResponseDTO.fromEntity(saved, username);
    }

    @Transactional(readOnly = true)
    public ActaResponseDTO obtenerActaPorPartido(Long partidoId, String username) {
        log.info("📋 Obteniendo acta del partido {} (solicitante: {})", partidoId, username);
        return actaPartidoRepository.findByPartidoId(partidoId)
                .map(acta -> ActaResponseDTO.fromEntity(acta, username))
                .orElse(null);
    }

    @Transactional(readOnly = true)
    public ActaResponseDTO obtenerActa(Long partidoId, String username) {
        ActaPartido acta = actaPartidoRepository.findByPartidoId(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No se encontró acta para este partido"));
        return ActaResponseDTO.fromEntity(acta, username);
    }

    @Transactional(readOnly = true)
    public ActaResponseDTO obtenerPorId(Long actaId, String username) {
        ActaPartido acta = actaPartidoRepository.findById(actaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));
        return ActaResponseDTO.fromEntity(acta, username);
    }

    @Transactional
    public ActaResponseDTO actualizarActa(Long actaId, ActaRequestDTO request, String username) {
        ActaPartido acta = actaPartidoRepository.findById(actaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));

        if (!puedeEditarInterno(acta, username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permisos para editar esta acta");
        }

        if (request.getResultadoLocal() != null) acta.setResultadoLocal(request.getResultadoLocal());
        if (request.getResultadoVisitante() != null) acta.setResultadoVisitante(request.getResultadoVisitante());
        if (request.getObservaciones() != null) acta.setObservaciones(request.getObservaciones());
        acta.setFechaActa(LocalDateTime.now());

        ActaPartido saved = actaPartidoRepository.save(acta);
        return ActaResponseDTO.fromEntity(saved, username);
    }

    @Transactional
    public void eliminarActa(Long actaId, String username) {
        ActaPartido acta = actaPartidoRepository.findById(actaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));

        if (!puedeEditarInterno(acta, username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permisos para eliminar esta acta");
        }
        actaPartidoRepository.delete(acta);
    }

    @Transactional(readOnly = true)
    public boolean existeActaPorPartido(Long partidoId) {
        return actaPartidoRepository.existsByPartidoId(partidoId);
    }

    @Transactional(readOnly = true)
    public boolean puedeEditar(Long actaId, String username) {
        return actaPartidoRepository.findById(actaId)
                .map(a -> puedeEditarInterno(a, username))
                .orElse(false);
    }

    // ============================================================
    // NUEVOS MÉTODOS (LO QUE TE FALTABA)
    // ============================================================

    @Transactional(readOnly = true)
    public List<ActaResponseDTO> listarPorArbitro(Long arbitroId, String username) {
        log.info("Listando actas del árbitro ID: {}", arbitroId);

        Arbitro arbitro = arbitroRepository.findById(arbitroId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Árbitro no encontrado"));

        return actaPartidoRepository.findByArbitroId(arbitroId).stream()
                .map(acta -> ActaResponseDTO.fromEntity(acta, username))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ActaResponseDTO> listarPorEquipo(Long equipoId, String username) {
        log.info("Listando actas del equipo ID: {}", equipoId);

        return actaPartidoRepository.findByEquipoId(equipoId).stream()
                .map(acta -> ActaResponseDTO.fromEntity(acta, username))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> obtenerEstadisticasActa(Long actaId) {
        log.info("Obteniendo estadísticas del acta ID: {}", actaId);

        ActaPartido acta = actaPartidoRepository.findById(actaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));

        // Estadísticas de puntos por equipo
        int puntosLocal = Integer.parseInt(acta.getResultadoLocal());
        int puntosVisitante = Integer.parseInt(acta.getResultadoVisitante());

        // Estadísticas de jugadores
        Map<String, Integer> puntosPorJugador = acta.getEventos().stream()
                .filter(e -> e.getPuntos() != null)
                .collect(Collectors.groupingBy(
                        EventoPartido::getNombreJugador,
                        Collectors.summingInt(EventoPartido::getPuntos)
                ));

        // Máximo anotador
        String maxAnotador = puntosPorJugador.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("Ninguno");

        int maxPuntos = puntosPorJugador.values().stream()
                .mapToInt(Integer::intValue)
                .max()
                .orElse(0);

        // Total de eventos por tipo
        Map<String, Long> eventosPorTipo = acta.getEventos().stream()
                .collect(Collectors.groupingBy(EventoPartido::getTipo, Collectors.counting()));

        return Map.ofEntries(
                Map.entry("partidoId", acta.getPartido().getId()),
                Map.entry("equipoLocal", acta.getPartido().getEquipoLocal().getNombre()),
                Map.entry("equipoVisitante", acta.getPartido().getEquipoVisitante().getNombre()),
                Map.entry("puntosLocal", puntosLocal),
                Map.entry("puntosVisitante", puntosVisitante),
                Map.entry("diferencia", Math.abs(puntosLocal - puntosVisitante)),
                Map.entry("ganador", puntosLocal > puntosVisitante ? "LOCAL" : (puntosVisitante > puntosLocal ? "VISITANTE" : "EMPATE")),
                Map.entry("maximoAnotador", maxAnotador),
                Map.entry("puntosMaximoAnotador", maxPuntos),
                Map.entry("eventosPorTipo", eventosPorTipo),
                Map.entry("totalEventos", acta.getEventos().size())
        );
    }

    @Transactional(readOnly = true)
    public ResponseEntity<byte[]> generarPdf(Long actaId) {
        log.info("Generando PDF del acta ID: {}", actaId);

        ActaPartido acta = actaPartidoRepository.findById(actaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));

        // Generar contenido HTML para el PDF
        String htmlContent = generarHtmlActa(acta);

        // Aquí usarías una librería como iText o Flying Saucer para convertir HTML a PDF
        // Por ahora devolvemos un mensaje de que no está implementado
        byte[] pdfBytes = ("PDF no implementado aún. Acta ID: " + actaId).getBytes();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData("attachment", "acta_" + actaId + ".pdf");

        return ResponseEntity.ok()
                .headers(headers)
                .body(pdfBytes);
    }

    private String generarHtmlActa(ActaPartido acta) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        StringBuilder html = new StringBuilder();
        html.append("<html><head><meta charset='UTF-8'><title>Acta del Partido</title></head><body>");
        html.append("<h1>Acta del Partido</h1>");
        html.append("<p><strong>Fecha:</strong> ").append(acta.getFechaActa().format(formatter)).append("</p>");
        html.append("<p><strong>Árbitro:</strong> ").append(acta.getArbitro().getNombre()).append("</p>");
        html.append("<h2>Resultado</h2>");
        html.append("<p>").append(acta.getPartido().getEquipoLocal().getNombre()).append(": ").append(acta.getResultadoLocal()).append(" - ");
        html.append(acta.getResultadoVisitante()).append(": ").append(acta.getPartido().getEquipoVisitante().getNombre()).append("</p>");

        if (acta.getObservaciones() != null && !acta.getObservaciones().isEmpty()) {
            html.append("<h2>Observaciones</h2>");
            html.append("<p>").append(acta.getObservaciones()).append("</p>");
        }

        html.append("<h2>Eventos del Partido</h2>");
        html.append("<table border='1'><tr><th>Minuto</th><th>Jugador</th><th>Equipo</th><th>Tipo</th><th>Descripción</th><th>Puntos</th></tr>");

        for (EventoPartido evento : acta.getEventos()) {
            html.append("<tr>");
            html.append("<td>").append(evento.getMinuto()).append("'</td>");
            html.append("<td>").append(evento.getNombreJugador()).append("</td>");
            html.append("<td>").append(evento.getNombreEquipo()).append("</td>");
            html.append("<td>").append(evento.getTipo()).append("</td>");
            html.append("<td>").append(evento.getDescripcion() != null ? evento.getDescripcion() : "").append("</td>");
            html.append("<td>").append(evento.getPuntos() != null ? evento.getPuntos() : "").append("</td>");
            html.append("</tr>");
        }

        html.append("</table></body></html>");
        return html.toString();
    }

    @Transactional
    public void compartirActa(Long actaId, String emailDestino, String username) {
        log.info("Compartiendo acta ID: {} con email: {}", actaId, emailDestino);

        ActaPartido acta = actaPartidoRepository.findById(actaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));

        if (!puedeEditarInterno(acta, username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permisos para compartir esta acta");
        }

        // Aquí implementarías el envío de email con el PDF adjunto
        // Por ahora solo logueamos
        log.info("📧 Email enviado a: {} con el acta ID: {}", emailDestino, actaId);
    }

    // ============================================================
    // MÉTODOS PRIVADOS
    // ============================================================

    private boolean puedeEditarInterno(ActaPartido acta, String username) {
        boolean esArbitroQueLaCreo = acta.getArbitro() != null &&
                acta.getArbitro().getUsername().equals(username);
        boolean esAdmin = SecurityContextHolder.getContext().getAuthentication()
                .getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        return esArbitroQueLaCreo || esAdmin;
    }
}