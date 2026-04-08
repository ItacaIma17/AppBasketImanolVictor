package Aplicacion.Services;

import Dominio.Entity.Equipo;
import Dominio.Entity.Liga;
import Dominio.Repositorys.EquipoRepository;
import Dominio.Repositorys.LigaRepository;
import Presentacion.DTOS.Equipo.EquipoRequest;
import Presentacion.DTOS.Equipo.EquipoResponse;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EquipoService {

    private final EquipoRepository equipoRepository;
    private final LigaRepository ligaRepository;

    @Transactional
    public EquipoResponse crearEquipo(EquipoRequest dto) {
        if (equipoRepository.existsByNombre(dto.getNombre()))
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un equipo con ese nombre");

        Liga liga = null;
        if (dto.getLigaId() != null) {
            liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.NOT_FOUND, "Liga no encontrada"));
        }

        Equipo equipo = new Equipo();
        equipo.setNombre(dto.getNombre());
        equipo.setNombreEstadio(dto.getNombreEstadio());
        equipo.setLiga(liga);

        return toResponse(equipoRepository.save(equipo));
    }

    public List<EquipoResponse> listarEquipos() {
        return equipoRepository.findAll()
                .stream().map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<EquipoResponse> listarPorLiga(Long ligaId) {
        return equipoRepository.findByLigaId(ligaId)
                .stream().map(this::toResponse)
                .collect(Collectors.toList());
    }

    public EquipoResponse obtenerEquipo(Long id) {
        Equipo equipo = equipoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Equipo no encontrado"));
        return toResponse(equipo);
    }

    @Transactional
    public EquipoResponse actualizarEquipo(Long id, EquipoRequest dto) {
        Equipo equipo = equipoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Equipo no encontrado"));

        if (dto.getNombre() != null) equipo.setNombre(dto.getNombre());
        if (dto.getNombreEstadio() != null) equipo.setNombreEstadio(dto.getNombreEstadio());
        if (dto.getLigaId() != null) {
            Liga liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.NOT_FOUND, "Liga no encontrada"));
            equipo.setLiga(liga);
        }

        return toResponse(equipoRepository.save(equipo));
    }

    @Transactional
    public void eliminarEquipo(Long id) {
        if (!equipoRepository.existsById(id))
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo no encontrado");
        equipoRepository.deleteById(id);
    }

    private EquipoResponse toResponse(Equipo equipo) {
        EquipoResponse r = new EquipoResponse();
        r.setId(equipo.getId());
        r.setNombre(equipo.getNombre());
        r.setNombreEstadio(equipo.getNombreEstadio());
        r.setLigaNombre(equipo.getLiga() != null ?
                equipo.getLiga().getNombreLiga() : null);
        r.setEntrenadorNombre(equipo.getEntrenador() != null ?
                equipo.getEntrenador().getNombre() + " " +
                        equipo.getEntrenador().getApellido() : null);
        r.setTotalJugadores(equipo.getJugadores().size());
        r.setJugadores(equipo.getJugadores().stream()
                .map(j -> j.getNombre() + " " + j.getApellido())
                .collect(Collectors.toList()));
        return r;
    }
}