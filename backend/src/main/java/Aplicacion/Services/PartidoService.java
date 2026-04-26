package Aplicacion.Services;

import Dominio.Entity.Partido;
import Dominio.Entity.Equipo;
import Dominio.Entity.Liga;
import Dominio.Entity.Arbitro;
import Dominio.Repositorys.PartidoRepository;
import Dominio.Repositorys.EquipoRepository;
import Dominio.Repositorys.LigaRepository;
import Dominio.Repositorys.ArbitroRepository;

import Presentacion.DTOS.Partido.PartidoRequest;
import Presentacion.DTOS.Partido.PartidoResponse;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PartidoService {

    private final PartidoRepository partidoRepository;
    private final EquipoRepository equipoRepository;
    private final LigaRepository ligaRepository;
    private final ArbitroRepository arbitroRepository;

    public List<PartidoResponse> listarPartidos() {
        return partidoRepository.findAll()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<PartidoResponse> obtenerPorEquipoLocal(Long id) {
        return partidoRepository.findByEquipoLocal_Id(id)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<PartidoResponse> obtenerPorEquipoVisitante(Long id) {
        return partidoRepository.findByEquipoVisitante_Id(id)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public PartidoResponse obtenerPorId(Long id) {
        Partido partido = partidoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Partido no encontrado"));
        return toResponse(partido);
    }

    public PartidoResponse crear(PartidoRequest dto) {

        Partido partido = new Partido();

        // Convertir IDs a entidades reales
        Equipo local = equipoRepository.findById(dto.getEquipoLocalId())
                .orElseThrow(() -> new RuntimeException("Equipo local no encontrado"));

        Equipo visitante = equipoRepository.findById(dto.getEquipoVisitanteId())
                .orElseThrow(() -> new RuntimeException("Equipo visitante no encontrado"));

        Liga liga = ligaRepository.findById(dto.getLigaId())
                .orElseThrow(() -> new RuntimeException("Liga no encontrada"));

        Arbitro arbitro = null;
        if (dto.getArbitroId() != null) {
            arbitro = arbitroRepository.findById(dto.getArbitroId())
                    .orElse(null);
        }

        partido.setEquipoLocal(local);
        partido.setEquipoVisitante(visitante);
        partido.setLiga(liga);
        partido.setArbitro(arbitro);

        partido.setFecha(java.time.LocalDate.parse(dto.getFecha()));
        partido.setHora(java.time.LocalTime.parse(dto.getHora()));

        partido.setPabellon(dto.getPabellon());
        partido.setDireccionPabellon(dto.getDireccionPabellon());

        partido.setEstado(Dominio.Entity.EstadoPartido.EstadoPartido.valueOf(dto.getEstado()));
        partido.setActaUrl(dto.getActaUrl());
        partido.setObservaciones(dto.getObservaciones());

        partidoRepository.save(partido);

        return toResponse(partido);
    }

    public void eliminar(Long id) {
        partidoRepository.deleteById(id);
    }

    private PartidoResponse toResponse(Partido partido) {
        PartidoResponse r = new PartidoResponse();

        r.setId(partido.getId());
        r.setEquipoLocalId(partido.getEquipoLocal().getId());
        r.setEquipoVisitanteId(partido.getEquipoVisitante().getId());

        r.setNombreLocal(partido.getEquipoLocal().getNombre());
        r.setNombreVisitante(partido.getEquipoVisitante().getNombre());

        r.setMarcadorLocal(partido.getMarcadorLocal());
        r.setMarcadorVisitante(partido.getMarcadorVisitante());

        r.setFecha(partido.getFecha().toString());
        r.setHora(partido.getHora().toString());

        r.setPabellon(partido.getPabellon());
        r.setDireccionPabellon(partido.getDireccionPabellon());

        r.setLigaId(partido.getLiga().getId());
        r.setArbitroId(partido.getArbitro() != null ? partido.getArbitro().getId() : null);

        r.setEstado(partido.getEstado().name());
        r.setActaUrl(partido.getActaUrl());
        r.setObservaciones(partido.getObservaciones());

        return r;
    }
}
