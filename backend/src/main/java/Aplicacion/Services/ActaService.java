package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Repositorys.ActaPartidoRepository;
import Dominio.Repositorys.ArbitroRepository;
import Dominio.Repositorys.PartidoRepository;
import Presentacion.DTOS.Arbitro.ActaRequestDTO;
import Presentacion.DTOS.Arbitro.ActaResponseDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class ActaService {

    private final ActaPartidoRepository actaPartidoRepository;
    private final PartidoRepository partidoRepository;
    private final ArbitroRepository arbitroRepository;

    @Transactional
    public ActaResponseDTO guardarActa(ActaRequestDTO request, String username) {
        log.info("========================================");
        log.info("📝 Guardando acta para partido ID: {}", request.getPartidoId());
        log.info("   Árbitro: {}", username);

        // Verificar que el acta no exista ya
        if (actaPartidoRepository.existsByPartidoId(request.getPartidoId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un acta para este partido");
        }

        // Buscar el árbitro
        Arbitro arbitro = arbitroRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado"));

        // Buscar el partido
        Partido partido = partidoRepository.findById(request.getPartidoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado"));

        // Verificar que el árbitro está asignado al partido
        if (partido.getArbitro() == null || !partido.getArbitro().getId().equals(arbitro.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "No tienes permisos para crear acta de este partido");
        }

        // Verificar que el partido no esté finalizado
        if ("FINALIZADO".equals(partido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "El partido ya está finalizado");
        }

        // Crear el acta
        ActaPartido acta = new ActaPartido();
        acta.setPartido(partido);
        acta.setArbitro(arbitro);
        acta.setFechaActa(LocalDateTime.now());
        acta.setResultadoLocal(request.getResultadoLocal());
        acta.setResultadoVisitante(request.getResultadoVisitante());
        acta.setObservaciones(request.getObservaciones());

        // Procesar eventos
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

                // Calcular puntos según tipo
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

        // Actualizar el resultado del partido
        partido.setResultadoLocal(Integer.parseInt(request.getResultadoLocal()));
        partido.setResultadoVisitante(Integer.parseInt(request.getResultadoVisitante()));
        partido.setEstado("FINALIZADO");
        partidoRepository.save(partido);

        ActaPartido saved = actaPartidoRepository.save(acta);
        log.info("✅ Acta guardada con ID: {}", saved.getId());
        log.info("========================================");

        return ActaResponseDTO.fromEntity(saved,username);
    }

    @Transactional(readOnly = true)
    public ActaResponseDTO obtenerActa(Long partidoId, String username) {
        log.info("🔍 Obteniendo acta para partido ID: {}", partidoId);

        ActaPartido acta = actaPartidoRepository.findByPartidoId(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "No se encontró acta para este partido"));

        // ✅ CORREGIDO: Pasar el username como segundo parámetro
        return ActaResponseDTO.fromEntity(acta, username);
    }
}