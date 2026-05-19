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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import jakarta.mail.MessagingException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ActaService {

    private final ActaPartidoRepository actaPartidoRepository;
    private final PartidoRepository partidoRepository;
    private final ArbitroRepository arbitroRepository;
    private final EquipoRepository equipoRepository;
    private final Dominio.Repositorys.JugadorRepository jugadorRepository;
    private final EmailService emailService;

    @Transactional
    public ActaResponseDTO guardarActa(ActaRequestDTO request, String username) {
        log.info(" Guardando acta para partido ID: {}", request.getPartidoId());

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

                if (eventoDTO.getJugadorId() != null) {
                    jugadorRepository.findById(eventoDTO.getJugadorId()).ifPresent(evento::setJugador);
                }

                acta.getEventos().add(evento);
            });
        }

        try {
            partido.setResultadoLocal(Integer.parseInt(request.getResultadoLocal() != null ? request.getResultadoLocal() : "0"));
            partido.setResultadoVisitante(Integer.parseInt(request.getResultadoVisitante() != null ? request.getResultadoVisitante() : "0"));
        } catch (NumberFormatException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Los resultados deben ser numéricos");
        }
        acta.setResultadoLocal(request.getResultadoLocal() != null ? request.getResultadoLocal() : "0");
        acta.setResultadoVisitante(request.getResultadoVisitante() != null ? request.getResultadoVisitante() : "0");
        partido.setEstado("FINALIZADO");

        ActaPartido saved = actaPartidoRepository.save(acta);
        log.info(" Acta guardada con ID: {}", saved.getId());

        partido.setActaPartido(saved);
        partidoRepository.save(partido);

        _actualizarStatsJugadores(saved);

        return ActaResponseDTO.fromEntity(saved, username);
    }

    @Transactional(readOnly = true)
    public ActaResponseDTO obtenerActaPorPartido(Long partidoId, String username) {
        log.info(" Obteniendo acta del partido {} (solicitante: {})", partidoId, username);
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

        Partido partido = acta.getPartido();
        if (request.getResultadoLocal() != null) {
            try {
                partido.setResultadoLocal(Integer.parseInt(request.getResultadoLocal()));
            } catch (NumberFormatException e) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Resultado local debe ser numérico");
            }
            acta.setResultadoLocal(request.getResultadoLocal());
        }
        if (request.getResultadoVisitante() != null) {
            try {
                partido.setResultadoVisitante(Integer.parseInt(request.getResultadoVisitante()));
            } catch (NumberFormatException e) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Resultado visitante debe ser numérico");
            }
            acta.setResultadoVisitante(request.getResultadoVisitante());
        }
        if (request.getObservaciones() != null) acta.setObservaciones(request.getObservaciones());
        acta.setFechaActa(LocalDateTime.now());

        if (request.getEventos() != null) {
            acta.getEventos().clear();
            request.getEventos().forEach(eventoDTO -> {
                EventoPartido evento = new EventoPartido();
                evento.setActa(acta);
                evento.setNombreJugador(eventoDTO.getNombreJugador());
                evento.setNombreEquipo(eventoDTO.getNombreEquipo());
                evento.setMinuto(eventoDTO.getMinuto());
                evento.setTipo(eventoDTO.getTipo());
                evento.setDescripcion(eventoDTO.getDescripcion());
                evento.setTimestamp(LocalDateTime.now());
                if ("CANASTA".equals(eventoDTO.getTipo())) evento.setPuntos(2);
                else if ("TIRO_3PUNTOS".equals(eventoDTO.getTipo())) evento.setPuntos(3);
                else if ("TIRO_LIBRE".equals(eventoDTO.getTipo())) evento.setPuntos(1);
                if (eventoDTO.getJugadorId() != null) {
                    jugadorRepository.findById(eventoDTO.getJugadorId()).ifPresent(evento::setJugador);
                }
                acta.getEventos().add(evento);
            });
        }

        partidoRepository.save(partido);

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
        Partido partido = acta.getPartido();
        partido.setEstado("PROGRAMADO");
        partido.setResultadoLocal(null);
        partido.setResultadoVisitante(null);
        partidoRepository.save(partido);
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
    public List<ActaResponseDTO> listarTodas() {
        return actaPartidoRepository.findAll().stream()
                .map(acta -> ActaResponseDTO.fromEntity(acta, null))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getEstadisticasJugadorEnPartido(Long partidoId, Long jugadorId) {
        ActaPartido acta = actaPartidoRepository.findByPartidoId(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada para el partido"));

        List<EventoPartido> eventosJugador = acta.getEventos().stream()
                .filter(e -> e.getJugador() != null && e.getJugador().getId().equals(jugadorId))
                .collect(Collectors.toList());

        int puntos = eventosJugador.stream()
                .filter(e -> e.getPuntos() != null).mapToInt(EventoPartido::getPuntos).sum();

        Map<String, Long> eventosPorTipo = eventosJugador.stream()
                .collect(Collectors.groupingBy(EventoPartido::getTipo, Collectors.counting()));

        Map<String, Object> result = new HashMap<>();
        result.put("partidoId", partidoId);
        result.put("jugadorId", jugadorId);
        result.put("puntos", puntos);
        result.put("totalEventos", eventosJugador.size());
        result.put("eventosPorTipo", eventosPorTipo);
        return result;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getEstadisticasEquipoEnPartido(Long partidoId, Long equipoId) {
        ActaPartido acta = actaPartidoRepository.findByPartidoId(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada para el partido"));

        String nombreEquipo = equipoRepository.findById(equipoId)
                .map(e -> e.getNombre()).orElse(null);

        List<EventoPartido> eventosEquipo = acta.getEventos().stream()
                .filter(e -> e.getNombreEquipo() != null && nombreEquipo != null
                        && e.getNombreEquipo().equals(nombreEquipo))
                .collect(Collectors.toList());

        int puntosTotales = eventosEquipo.stream()
                .filter(e -> e.getPuntos() != null).mapToInt(EventoPartido::getPuntos).sum();

        Map<String, Long> eventosPorTipo = eventosEquipo.stream()
                .collect(Collectors.groupingBy(EventoPartido::getTipo, Collectors.counting()));

        Map<String, Object> result = new HashMap<>();
        result.put("partidoId", partidoId);
        result.put("equipoId", equipoId);
        result.put("nombreEquipo", nombreEquipo);
        result.put("puntosTotales", puntosTotales);
        result.put("totalEventos", eventosEquipo.size());
        result.put("eventosPorTipo", eventosPorTipo);
        return result;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> obtenerEstadisticasActa(Long actaId) {
        log.info("Obteniendo estadísticas del acta ID: {}", actaId);

        ActaPartido acta = actaPartidoRepository.findById(actaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));

        int puntosLocal = 0;
        int puntosVisitante = 0;
        try {
            if (acta.getResultadoLocal() != null) puntosLocal = Integer.parseInt(acta.getResultadoLocal());
            if (acta.getResultadoVisitante() != null) puntosVisitante = Integer.parseInt(acta.getResultadoVisitante());
        } catch (NumberFormatException e) {
            log.warn("Resultado no numérico en acta {}: local={}, visitante={}", actaId,
                    acta.getResultadoLocal(), acta.getResultadoVisitante());
        }

        Map<String, Integer> puntosPorJugador = acta.getEventos().stream()
                .filter(e -> e.getPuntos() != null)
                .collect(Collectors.groupingBy(
                        EventoPartido::getNombreJugador,
                        Collectors.summingInt(EventoPartido::getPuntos)
                ));

        String maxAnotador = puntosPorJugador.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("Ninguno");

        int maxPuntos = puntosPorJugador.values().stream()
                .mapToInt(Integer::intValue)
                .max()
                .orElse(0);

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

    @Transactional
    public ActaResponseDTO subirArchivoActa(Long partidoId, MultipartFile archivo,
                                             String resultadoLocal, String resultadoVisitante,
                                             String observaciones, String username) {
        log.info("Subiendo archivo de acta para partido ID: {}", partidoId);

        Arbitro arbitro = arbitroRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Árbitro no encontrado"));

        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

        if (partido.getArbitro() == null || !partido.getArbitro().getId().equals(arbitro.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permisos para crear acta de este partido");
        }

        ActaPartido acta = actaPartidoRepository.findByPartidoId(partidoId).orElseGet(() -> {
            ActaPartido nueva = new ActaPartido();
            nueva.setPartido(partido);
            nueva.setArbitro(arbitro);
            nueva.setFechaActa(LocalDateTime.now());
            return nueva;
        });

        try {
            acta.setArchivoActa(archivo.getBytes());
            acta.setTipoArchivoActa(archivo.getContentType());
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Error procesando el archivo");
        }

        String resLocal = (resultadoLocal != null && !resultadoLocal.isBlank()) ? resultadoLocal : "0";
        String resVisitante = (resultadoVisitante != null && !resultadoVisitante.isBlank()) ? resultadoVisitante : "0";
        acta.setResultadoLocal(resLocal);
        acta.setResultadoVisitante(resVisitante);
        if (observaciones != null) acta.setObservaciones(observaciones);

        try {
            partido.setResultadoLocal(Integer.parseInt(resLocal));
            partido.setResultadoVisitante(Integer.parseInt(resVisitante));
        } catch (NumberFormatException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Los resultados deben ser numéricos");
        }
        partido.setEstado("FINALIZADO");

        ActaPartido saved = actaPartidoRepository.save(acta);
        log.info("Archivo de acta subido con ID: {}", saved.getId());

        partido.setActaPartido(saved);
        partidoRepository.save(partido);
        return ActaResponseDTO.fromEntity(saved, username);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<byte[]> generarPdf(Long actaId) {
        log.info("Generando PDF del acta ID: {}", actaId);

        ActaPartido acta = actaPartidoRepository.findById(actaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));

        try {
            byte[] pdfBytes;
            String filename = "acta_partido_" + acta.getPartido().getId() + ".pdf";

            if (acta.getArchivoActa() != null && acta.getArchivoActa().length > 0) {
                String tipo = acta.getTipoArchivoActa();
                if ("application/pdf".equals(tipo)) {
                    pdfBytes = acta.getArchivoActa();
                } else {
                    pdfBytes = buildPdfConImagen(acta);
                }
            } else {
                pdfBytes = buildPdf(acta);
            }

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment", filename);
            return ResponseEntity.ok().headers(headers).body(pdfBytes);
        } catch (Exception e) {
            log.error("Error generando PDF del acta {}", actaId, e);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error generando PDF");
        }
    }

    @Transactional(readOnly = true)
    public ResponseEntity<byte[]> generarPdfPorPartido(Long partidoId) {
        ActaPartido acta = actaPartidoRepository.findByPartidoId(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No hay acta para este partido"));
        return generarPdf(acta.getId());
    }

    private byte[] buildPdfConImagen(ActaPartido acta) throws Exception {
        com.itextpdf.text.Document doc = new com.itextpdf.text.Document(
                com.itextpdf.text.PageSize.A4, 20, 20, 20, 20);
        java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
        com.itextpdf.text.pdf.PdfWriter.getInstance(doc, baos);
        doc.open();
        com.itextpdf.text.Image img = com.itextpdf.text.Image.getInstance(acta.getArchivoActa());
        float pageWidth = doc.getPageSize().getWidth() - 40;
        float pageHeight = doc.getPageSize().getHeight() - 40;
        img.scaleToFit(pageWidth, pageHeight);
        img.setAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
        doc.add(img);
        doc.close();
        return baos.toByteArray();
    }

    private byte[] buildPdf(ActaPartido acta) throws Exception {
        com.itextpdf.text.Document doc = new com.itextpdf.text.Document(com.itextpdf.text.PageSize.A4, 36, 36, 54, 36);
        java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
        com.itextpdf.text.pdf.PdfWriter.getInstance(doc, baos);
        doc.open();

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        com.itextpdf.text.Font fontTitulo = com.itextpdf.text.FontFactory.getFont(
                com.itextpdf.text.FontFactory.HELVETICA_BOLD, 18, com.itextpdf.text.BaseColor.BLACK);
        com.itextpdf.text.Font fontSeccion = com.itextpdf.text.FontFactory.getFont(
                com.itextpdf.text.FontFactory.HELVETICA_BOLD, 12, com.itextpdf.text.BaseColor.BLACK);
        com.itextpdf.text.Font fontNormal = com.itextpdf.text.FontFactory.getFont(
                com.itextpdf.text.FontFactory.HELVETICA, 10, com.itextpdf.text.BaseColor.BLACK);
        com.itextpdf.text.Font fontBold = com.itextpdf.text.FontFactory.getFont(
                com.itextpdf.text.FontFactory.HELVETICA_BOLD, 10, com.itextpdf.text.BaseColor.BLACK);
        com.itextpdf.text.Font fontResultado = com.itextpdf.text.FontFactory.getFont(
                com.itextpdf.text.FontFactory.HELVETICA_BOLD, 28, com.itextpdf.text.BaseColor.BLACK);
        com.itextpdf.text.Font fontEquipo = com.itextpdf.text.FontFactory.getFont(
                com.itextpdf.text.FontFactory.HELVETICA_BOLD, 13, com.itextpdf.text.BaseColor.BLACK);

        // Título
        com.itextpdf.text.Paragraph titulo = new com.itextpdf.text.Paragraph("ACTA DEL PARTIDO", fontTitulo);
        titulo.setAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
        doc.add(titulo);
        doc.add(new com.itextpdf.text.Paragraph(" "));

        // Resultado
        com.itextpdf.text.pdf.PdfPTable tablaResultado = new com.itextpdf.text.pdf.PdfPTable(3);
        tablaResultado.setWidthPercentage(100);
        tablaResultado.setWidths(new float[]{3, 2, 3});

        com.itextpdf.text.pdf.PdfPCell cellLocal = new com.itextpdf.text.pdf.PdfPCell(
                new com.itextpdf.text.Phrase(acta.getPartido().getEquipoLocal().getNombre(), fontEquipo));
        cellLocal.setHorizontalAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
        cellLocal.setBorder(0);
        cellLocal.setPadding(8);

        String resultado = acta.getResultadoLocal() + " - " + acta.getResultadoVisitante();
        com.itextpdf.text.pdf.PdfPCell cellResultado = new com.itextpdf.text.pdf.PdfPCell(
                new com.itextpdf.text.Phrase(resultado, fontResultado));
        cellResultado.setHorizontalAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
        cellResultado.setVerticalAlignment(com.itextpdf.text.Element.ALIGN_MIDDLE);
        cellResultado.setBorder(com.itextpdf.text.Rectangle.BOX);
        cellResultado.setPadding(10);
        cellResultado.setBackgroundColor(new com.itextpdf.text.BaseColor(245, 245, 245));

        com.itextpdf.text.pdf.PdfPCell cellVisitante = new com.itextpdf.text.pdf.PdfPCell(
                new com.itextpdf.text.Phrase(acta.getPartido().getEquipoVisitante().getNombre(), fontEquipo));
        cellVisitante.setHorizontalAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
        cellVisitante.setBorder(0);
        cellVisitante.setPadding(8);

        tablaResultado.addCell(cellLocal);
        tablaResultado.addCell(cellResultado);
        tablaResultado.addCell(cellVisitante);
        doc.add(tablaResultado);
        doc.add(new com.itextpdf.text.Paragraph(" "));

        // Info árbitro y fecha
        com.itextpdf.text.pdf.PdfPTable tablaInfo = new com.itextpdf.text.pdf.PdfPTable(2);
        tablaInfo.setWidthPercentage(100);
        com.itextpdf.text.pdf.PdfPCell cellArbitro = new com.itextpdf.text.pdf.PdfPCell();
        cellArbitro.addElement(new com.itextpdf.text.Paragraph("Árbitro: " + acta.getArbitro().getNombre(), fontNormal));
        cellArbitro.setBorder(0);
        com.itextpdf.text.pdf.PdfPCell cellFecha = new com.itextpdf.text.pdf.PdfPCell();
        cellFecha.addElement(new com.itextpdf.text.Paragraph("Fecha: " + acta.getFechaActa().format(fmt), fontNormal));
        cellFecha.setBorder(0);
        tablaInfo.addCell(cellArbitro);
        tablaInfo.addCell(cellFecha);
        doc.add(tablaInfo);

        if (acta.getObservaciones() != null && !acta.getObservaciones().isBlank()) {
            doc.add(new com.itextpdf.text.Paragraph(" "));
            doc.add(new com.itextpdf.text.Paragraph("Observaciones:", fontBold));
            doc.add(new com.itextpdf.text.Paragraph(acta.getObservaciones(), fontNormal));
        }

        doc.add(new com.itextpdf.text.Paragraph(" "));

        // Eventos
        doc.add(new com.itextpdf.text.Paragraph("Eventos del Partido (" + acta.getEventos().size() + ")", fontSeccion));
        doc.add(new com.itextpdf.text.Paragraph(" "));

        if (!acta.getEventos().isEmpty()) {
            com.itextpdf.text.pdf.PdfPTable tablaEventos = new com.itextpdf.text.pdf.PdfPTable(5);
            tablaEventos.setWidthPercentage(100);
            tablaEventos.setWidths(new float[]{1, 2.5f, 2f, 2f, 1});

            String[] headers = {"Min.", "Jugador", "Equipo", "Tipo", "Pts"};
            com.itextpdf.text.BaseColor headerBg = new com.itextpdf.text.BaseColor(230, 230, 230);
            for (String h : headers) {
                com.itextpdf.text.pdf.PdfPCell hCell = new com.itextpdf.text.pdf.PdfPCell(
                        new com.itextpdf.text.Phrase(h, fontBold));
                hCell.setBackgroundColor(headerBg);
                hCell.setHorizontalAlignment(com.itextpdf.text.Element.ALIGN_CENTER);
                hCell.setPadding(5);
                tablaEventos.addCell(hCell);
            }

            List<EventoPartido> eventosOrdenados = acta.getEventos().stream()
                    .sorted(java.util.Comparator.comparingInt(EventoPartido::getMinuto))
                    .collect(Collectors.toList());

            boolean alternado = false;
            com.itextpdf.text.BaseColor rowAlt = new com.itextpdf.text.BaseColor(250, 250, 250);
            for (EventoPartido ev : eventosOrdenados) {
                com.itextpdf.text.BaseColor bg = alternado ? rowAlt : com.itextpdf.text.BaseColor.WHITE;
                addEventoCell(tablaEventos, ev.getMinuto() + "'", fontNormal, bg, com.itextpdf.text.Element.ALIGN_CENTER);
                addEventoCell(tablaEventos, ev.getNombreJugador(), fontNormal, bg, com.itextpdf.text.Element.ALIGN_LEFT);
                addEventoCell(tablaEventos, ev.getNombreEquipo(), fontNormal, bg, com.itextpdf.text.Element.ALIGN_LEFT);
                addEventoCell(tablaEventos, tipoLabel(ev.getTipo()), fontNormal, bg, com.itextpdf.text.Element.ALIGN_LEFT);
                addEventoCell(tablaEventos, ev.getPuntos() != null ? String.valueOf(ev.getPuntos()) : "-", fontNormal, bg, com.itextpdf.text.Element.ALIGN_CENTER);
                alternado = !alternado;
            }
            doc.add(tablaEventos);
        } else {
            doc.add(new com.itextpdf.text.Paragraph("Sin eventos registrados.", fontNormal));
        }

        doc.close();
        return baos.toByteArray();
    }

    private void addEventoCell(com.itextpdf.text.pdf.PdfPTable table, String text,
                                com.itextpdf.text.Font font, com.itextpdf.text.BaseColor bg, int align) {
        com.itextpdf.text.pdf.PdfPCell cell = new com.itextpdf.text.pdf.PdfPCell(
                new com.itextpdf.text.Phrase(text != null ? text : "", font));
        cell.setBackgroundColor(bg);
        cell.setHorizontalAlignment(align);
        cell.setPadding(4);
        table.addCell(cell);
    }

    private String tipoLabel(String tipo) {
        if (tipo == null) return "";
        switch (tipo) {
            case "CANASTA": return "Canasta (2)";
            case "TIRO_3PUNTOS": return "Triple (3)";
            case "TIRO_LIBRE": return "Tiro libre (1)";
            case "FALTA": return "Falta";
            case "TECNICA": return "T. Técnica";
            default: return tipo;
        }
    }

    @Transactional(readOnly = true)
    public void compartirActa(Long actaId, String emailDestino, String username) {
        log.info("Compartiendo acta ID: {} con email: {}", actaId, emailDestino);

        ActaPartido acta = actaPartidoRepository.findById(actaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));

        if (!puedeEditarInterno(acta, username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permisos para compartir esta acta");
        }

        try {
            ResponseEntity<byte[]> pdfResponse = generarPdf(actaId);
            byte[] pdfBytes = pdfResponse.getBody();
            if (pdfBytes == null || pdfBytes.length == 0) {
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error generando PDF para compartir");
            }

            String equipoLocal = acta.getPartido() != null && acta.getPartido().getEquipoLocal() != null
                    ? acta.getPartido().getEquipoLocal().getNombre() : "Local";
            String equipoVisitante = acta.getPartido() != null && acta.getPartido().getEquipoVisitante() != null
                    ? acta.getPartido().getEquipoVisitante().getNombre() : "Visitante";
            String filename = "acta_" + equipoLocal + "_vs_" + equipoVisitante + ".pdf";

            String htmlContent = String.format("""
                <h2>Acta del Partido</h2>
                <p><strong>%s vs %s</strong></p>
                <p>Resultado: %s - %s</p>
                <p>Árbitro: %s</p>
                <p>Se adjunta el acta del partido en formato PDF.</p>
                <br>
                <p><em>Federación Aragonesa de Baloncesto</em></p>
                """,
                    equipoLocal, equipoVisitante,
                    acta.getResultadoLocal(), acta.getResultadoVisitante(),
                    acta.getArbitro() != null ? acta.getArbitro().getNombre() : "");

            emailService.sendHtmlMailWithAttachment(emailDestino,
                    "Acta del partido: " + equipoLocal + " vs " + equipoVisitante,
                    htmlContent, pdfBytes, filename);

            log.info("Acta ID {} enviada por email a: {}", actaId, emailDestino);
        } catch (MessagingException e) {
            log.error("Error enviando email del acta {}: {}", actaId, e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error enviando el email");
        }
    }

    private void _actualizarStatsJugadores(ActaPartido acta) {
        Map<Long, Integer> puntosPorJugador = new HashMap<>();
        Set<Long> jugadorIds = new HashSet<>();
        acta.getEventos().forEach(e -> {
            if (e.getJugador() != null) {
                jugadorIds.add(e.getJugador().getId());
                if (e.getPuntos() != null) {
                    puntosPorJugador.merge(e.getJugador().getId(), e.getPuntos(), Integer::sum);
                }
            }
        });
        jugadorIds.forEach(jId -> jugadorRepository.findById(jId).ifPresent(j -> {
            j.setPuntosTotales(j.getPuntosTotales() + puntosPorJugador.getOrDefault(jId, 0));
            j.setPartidosJugados(j.getPartidosJugados() + 1);
            jugadorRepository.save(j);
        }));
    }

    private boolean puedeEditarInterno(ActaPartido acta, String username) {
        boolean esArbitroQueLaCreo = acta.getArbitro() != null &&
                acta.getArbitro().getUsername().equals(username);
        boolean esAdmin = SecurityContextHolder.getContext().getAuthentication()
                .getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        return esArbitroQueLaCreo || esAdmin;
    }
}
