package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Repositorys.*;
import Presentacion.DTOS.Alineacion.AlineacionesPartidoDTO;
import Presentacion.DTOS.Entrenador.AlineacionRequestDTO;
import Presentacion.DTOS.Entrenador.AlineacionResponseDTO;
import Presentacion.DTOS.Jugador.JugadorAlineacionRequestDTO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
public class AlineacionService {

    @Autowired
    private AlineacionRepository alineacionRepository;

    @Autowired
    private PartidoRepository partidoRepository;

    @Autowired
    private EquipoRepository equipoRepository;

    @Autowired
    private EntrenadorRepository entrenadorRepository;

    @Autowired
    private JugadorRepository jugadorRepository;

    @Autowired
    private ArbitroRepository arbitroRepository;

    @Autowired
    private NotificacionService notificacionService;

    private static final int MAX_TITULARES = 5;
    private static final int MAX_SUPLENTES = 7;

    @Transactional
    public AlineacionResponseDTO presentarAlineacion(AlineacionRequestDTO dto, String username) {

        Partido partido = partidoRepository.findById(dto.getPartidoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + dto.getPartidoId()));

        if ("FINALIZADO".equals(partido.getEstado())) {
            throw new IllegalStateException("No se puede presentar alineación para un partido finalizado");
        }

        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado con username: " + username));

        if (entrenador.getEquipo() == null) {
            throw new IllegalStateException("No tienes un equipo asignado");
        }

        Long equipoId = entrenador.getEquipo().getId();

        boolean participa = partido.getEquipoLocal().getId().equals(equipoId) ||
                partido.getEquipoVisitante().getId().equals(equipoId);

        if (!participa) {
            throw new IllegalStateException("Tu equipo no participa en este partido");
        }

        Optional<Alineacion> existente = alineacionRepository.findByPartidoIdAndEquipoId(dto.getPartidoId(), equipoId);

        if (existente.isPresent()) {
            Alineacion alineacionExistente = existente.get();
            if (alineacionExistente.isConfirmada()) {
                throw new IllegalStateException("La alineación ya fue confirmada por el árbitro y no puede modificarse");
            }
            if (alineacionExistente.isBloqueada()) {
                throw new IllegalStateException("La alineación está bloqueada y no puede modificarse");
            }
            return actualizarAlineacion(alineacionExistente.getId(), dto, username);
        }

        if (dto.getTitulares() == null || dto.getTitulares().size() != MAX_TITULARES) {
            throw new IllegalStateException("Debes seleccionar exactamente " + MAX_TITULARES + " titulares");
        }

        Set<Long> titularesIds = dto.getTitulares().stream()
                .map(JugadorAlineacionRequestDTO::getJugadorId)
                .collect(Collectors.toSet());
        Set<Long> suplentesIds = dto.getSuplentes().stream()
                .map(JugadorAlineacionRequestDTO::getJugadorId)
                .collect(Collectors.toSet());

        Set<Long> duplicados = new HashSet<>(titularesIds);
        duplicados.retainAll(suplentesIds);
        if (!duplicados.isEmpty()) {
            throw new IllegalStateException("Un jugador no puede estar en titulares y suplentes a la vez");
        }

        Alineacion alineacion = new Alineacion();
        alineacion.setPartido(partido);
        alineacion.setEquipo(entrenador.getEquipo());
        alineacion.setEntrenador(entrenador);
        alineacion.setFechaPresentacion(LocalDateTime.now());
        alineacion.setConfirmada(false);
        alineacion.setBloqueada(false);

        for (JugadorAlineacionRequestDTO jugadorDTO : dto.getTitulares()) {
            Jugador jugador = jugadorRepository.findById(jugadorDTO.getJugadorId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Jugador no encontrado con ID: " + jugadorDTO.getJugadorId()));

            JugadorAlineacion ja = new JugadorAlineacion();
            ja.setAlineacion(alineacion);
            ja.setJugador(jugador);
            ja.setTitular(true);
            ja.setDorsal(jugadorDTO.getDorsal() > 0 ? jugadorDTO.getDorsal() : jugador.getDorsal());
            ja.setPosicion(jugadorDTO.getPosicion() != null && !jugadorDTO.getPosicion().isEmpty() ?
                    jugadorDTO.getPosicion() : jugador.getPosicion());
            ja.setNombreJugador(jugador.getNombre());
            ja.setApellidoJugador(jugador.getApellido());
            alineacion.getJugadores().add(ja);
        }

        for (JugadorAlineacionRequestDTO jugadorDTO : dto.getSuplentes()) {
            Jugador jugador = jugadorRepository.findById(jugadorDTO.getJugadorId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Jugador no encontrado con ID: " + jugadorDTO.getJugadorId()));

            JugadorAlineacion ja = new JugadorAlineacion();
            ja.setAlineacion(alineacion);
            ja.setJugador(jugador);
            ja.setTitular(false);
            ja.setDorsal(jugadorDTO.getDorsal() > 0 ? jugadorDTO.getDorsal() : jugador.getDorsal());
            ja.setPosicion(jugadorDTO.getPosicion() != null && !jugadorDTO.getPosicion().isEmpty() ?
                    jugadorDTO.getPosicion() : jugador.getPosicion());
            ja.setNombreJugador(jugador.getNombre());
            ja.setApellidoJugador(jugador.getApellido());
            alineacion.getJugadores().add(ja);
        }

        Alineacion saved = alineacionRepository.save(alineacion);
        notificacionService.notificarAlineacionPresentada(saved);
        return AlineacionResponseDTO.fromEntity(saved);
    }

    public boolean ambasAlineacionesConfirmadas(Long partidoId) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

        Optional<Alineacion> alineacionLocal = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoLocal().getId());
        Optional<Alineacion> alineacionVisitante = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoVisitante().getId());

        return alineacionLocal.isPresent() && alineacionLocal.get().isConfirmada()
                && alineacionVisitante.isPresent() && alineacionVisitante.get().isConfirmada();
    }

    @Transactional
    public AlineacionResponseDTO actualizarAlineacion(Long id, AlineacionRequestDTO dto, String username) {
        Alineacion alineacion = alineacionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Alineación no encontrada con ID: " + id));

        if (!alineacion.getEntrenador().getUsername().equals(username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "No tienes permiso para modificar esta alineación");
        }

        if (alineacion.isConfirmada()) {
            throw new IllegalStateException("La alineación ya fue confirmada por el árbitro y no puede modificarse");
        }

        if (alineacion.isBloqueada()) {
            throw new IllegalStateException("La alineación está bloqueada y no puede modificarse");
        }

        alineacion.getJugadores().clear();

        for (JugadorAlineacionRequestDTO jugadorDTO : dto.getTitulares()) {
            Jugador jugador = jugadorRepository.findById(jugadorDTO.getJugadorId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Jugador no encontrado con ID: " + jugadorDTO.getJugadorId()));

            JugadorAlineacion ja = new JugadorAlineacion();
            ja.setAlineacion(alineacion);
            ja.setJugador(jugador);
            ja.setTitular(true);
            ja.setDorsal(jugadorDTO.getDorsal() > 0 ? jugadorDTO.getDorsal() : jugador.getDorsal());
            ja.setPosicion(jugadorDTO.getPosicion() != null && !jugadorDTO.getPosicion().isEmpty() ?
                    jugadorDTO.getPosicion() : jugador.getPosicion());
            ja.setNombreJugador(jugador.getNombre());
            ja.setApellidoJugador(jugador.getApellido());
            alineacion.getJugadores().add(ja);
        }

        for (JugadorAlineacionRequestDTO jugadorDTO : dto.getSuplentes()) {
            Jugador jugador = jugadorRepository.findById(jugadorDTO.getJugadorId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Jugador no encontrado con ID: " + jugadorDTO.getJugadorId()));

            JugadorAlineacion ja = new JugadorAlineacion();
            ja.setAlineacion(alineacion);
            ja.setJugador(jugador);
            ja.setTitular(false);
            ja.setDorsal(jugadorDTO.getDorsal() > 0 ? jugadorDTO.getDorsal() : jugador.getDorsal());
            ja.setPosicion(jugadorDTO.getPosicion() != null && !jugadorDTO.getPosicion().isEmpty() ?
                    jugadorDTO.getPosicion() : jugador.getPosicion());
            ja.setNombreJugador(jugador.getNombre());
            ja.setApellidoJugador(jugador.getApellido());
            alineacion.getJugadores().add(ja);
        }

        alineacion.setFechaPresentacion(LocalDateTime.now());
        Alineacion saved = alineacionRepository.save(alineacion);
        return AlineacionResponseDTO.fromEntity(saved);
    }

    @Transactional
    public void eliminarAlineacion(Long id, String username) {
        Alineacion alineacion = alineacionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Alineación no encontrada con ID: " + id));

        Partido partido = alineacion.getPartido();
        Arbitro arbitro = partido.getArbitro();

        boolean esArbitro = arbitro != null && arbitro.getUsername().equals(username);
        boolean esAdmin = "admin".equals(username);

        if (!esArbitro && !esAdmin) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "No tienes permiso para eliminar esta alineación");
        }

        alineacionRepository.delete(alineacion);
    }

    @Transactional
    public AlineacionResponseDTO confirmarAlineacion(Long id, String username) {
        Alineacion alineacion = alineacionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Alineación no encontrada con ID: " + id));

        Partido partido = alineacion.getPartido();
        Arbitro arbitro = partido.getArbitro();

        if (arbitro == null || !arbitro.getUsername().equals(username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "No tienes permiso para confirmar esta alineación");
        }

        alineacion.setConfirmada(true);
        alineacion.setBloqueada(true);

        Alineacion saved = alineacionRepository.save(alineacion);

        String emailEntrenador = alineacion.getEntrenador() != null ? alineacion.getEntrenador().getEmail() : null;
        String nombreEquipo = alineacion.getEquipo() != null ? alineacion.getEquipo().getNombre() : "tu equipo";
        notificacionService.notificarAlineacionConfirmada(partido, emailEntrenador, nombreEquipo);

        return AlineacionResponseDTO.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getAlineacionesPartido(Long partidoId) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + partidoId));

        Optional<Alineacion> alineacionLocal = alineacionRepository.findByPartidoIdAndEquipoId(
                partidoId, partido.getEquipoLocal().getId());

        Optional<Alineacion> alineacionVisitante = alineacionRepository.findByPartidoIdAndEquipoId(
                partidoId, partido.getEquipoVisitante().getId());

        Map<String, Object> response = new HashMap<>();
        response.put("partidoId", partidoId);
        response.put("equipoLocal", partido.getEquipoLocal().getNombre());
        response.put("equipoVisitante", partido.getEquipoVisitante().getNombre());
        response.put("alineacionLocal", alineacionLocal.map(AlineacionResponseDTO::fromEntity).orElse(null));
        response.put("alineacionVisitante", alineacionVisitante.map(AlineacionResponseDTO::fromEntity).orElse(null));
        response.put("ambasPresentadas", alineacionLocal.isPresent() && alineacionVisitante.isPresent());
        response.put("partidoListoParaComenzar",
                alineacionLocal.isPresent() && alineacionLocal.get().isConfirmada() &&
                        alineacionVisitante.isPresent() && alineacionVisitante.get().isConfirmada());

        return response;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getAlineacionEquipoEnPartido(Long partidoId, Long equipoId) {
        Optional<Alineacion> alineacion = alineacionRepository.findByPartidoIdAndEquipoId(partidoId, equipoId);

        if (alineacion.isEmpty()) {
            return null;
        }

        Alineacion a = alineacion.get();
        Map<String, Object> response = new HashMap<>();
        response.put("id", a.getId());
        response.put("equipoId", a.getEquipo().getId());
        response.put("nombreEquipo", a.getEquipo().getNombre());
        response.put("confirmada", a.isConfirmada());
        response.put("bloqueada", a.isBloqueada());
        response.put("fechaPresentacion", a.getFechaPresentacion());

        response.put("titulares", a.getTitulares().stream()
                .map(ja -> {
                    Map<String, Object> j = new HashMap<>();
                    j.put("jugadorId", ja.getJugador().getId());
                    j.put("nombre", ja.getNombreJugador() + " " + (ja.getApellidoJugador() != null ? ja.getApellidoJugador() : ""));
                    j.put("dorsal", ja.getDorsal());
                    j.put("posicion", ja.getPosicion());
                    return j;
                })
                .collect(Collectors.toList()));

        response.put("suplentes", a.getSuplentes().stream()
                .map(ja -> {
                    Map<String, Object> j = new HashMap<>();
                    j.put("jugadorId", ja.getJugador().getId());
                    j.put("nombre", ja.getNombreJugador() + " " + (ja.getApellidoJugador() != null ? ja.getApellidoJugador() : ""));
                    j.put("dorsal", ja.getDorsal());
                    j.put("posicion", ja.getPosicion());
                    return j;
                })
                .collect(Collectors.toList()));

        return response;
    }

    @Transactional(readOnly = true)
    public List<AlineacionResponseDTO> listarTodas() {
        return alineacionRepository.findAll().stream()
                .map(AlineacionResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getAlineacionMap(Long partidoId, Long equipoId) {
        Optional<Alineacion> alineacion = alineacionRepository.findByPartidoIdAndEquipoId(partidoId, equipoId);

        if (alineacion.isEmpty()) {
            return null;
        }

        Alineacion a = alineacion.get();
        Map<String, Object> response = new HashMap<>();
        response.put("id", a.getId());
        response.put("equipoId", a.getEquipo().getId());
        response.put("nombreEquipo", a.getEquipo().getNombre());
        response.put("confirmada", a.isConfirmada());

        response.put("titulares", a.getTitulares().stream()
                .map(ja -> {
                    Map<String, Object> j = new HashMap<>();
                    j.put("jugadorId", ja.getJugador().getId());
                    j.put("nombre", ja.getNombreJugador() + " " + (ja.getApellidoJugador() != null ? ja.getApellidoJugador() : ""));
                    j.put("dorsal", ja.getDorsal());
                    j.put("posicion", ja.getPosicion());
                    j.put("esTitular", true);
                    return j;
                })
                .collect(Collectors.toList()));

        response.put("suplentes", a.getSuplentes().stream()
                .map(ja -> {
                    Map<String, Object> j = new HashMap<>();
                    j.put("jugadorId", ja.getJugador().getId());
                    j.put("nombre", ja.getNombreJugador() + " " + (ja.getApellidoJugador() != null ? ja.getApellidoJugador() : ""));
                    j.put("dorsal", ja.getDorsal());
                    j.put("posicion", ja.getPosicion());
                    j.put("esTitular", false);
                    return j;
                })
                .collect(Collectors.toList()));

        return response;
    }

    @Transactional(readOnly = true)
    public AlineacionesPartidoDTO getAlineacionesParaActa(Long partidoId) {
        log.info("Obteniendo alineaciones para acta del partido: {}", partidoId);

        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado: " + partidoId));

        AlineacionResponseDTO alineacionLocal = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoLocal().getId())
                .map(AlineacionResponseDTO::fromEntity)
                .orElse(null);

        AlineacionResponseDTO alineacionVisitante = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoVisitante().getId())
                .map(AlineacionResponseDTO::fromEntity)
                .orElse(null);

        return AlineacionesPartidoDTO.fromEntities(
                alineacionLocal,
                alineacionVisitante,
                partidoId,
                partido.getEquipoLocal().getNombre(),
                partido.getEquipoVisitante().getNombre()
        );
    }
}
