// Aplicacion/Services/EquipoService.java
package Aplicacion.Services;

import Dominio.Entity.Equipo;
import Dominio.Entity.Liga;
import Dominio.Repositorys.EquipoRepository;
import Dominio.Repositorys.LigaRepository;
import Presentacion.DTOS.Equipo.ActualizarEquipoDTO;
import Presentacion.DTOS.Equipo.CrearEquipoDTO;
import Presentacion.DTOS.Equipo.EquipoRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class EquipoService {

    private final EquipoRepository equipoRepository;
    private final LigaRepository ligaRepository;

    // Crear equipo
    @Transactional
    public EquipoRequest crearEquipo(CrearEquipoDTO dto) {
        log.info("Creando equipo: {}", dto.getNombre());

        // Verificar que no exista un equipo con el mismo nombre
        if (equipoRepository.existsByNombre(dto.getNombre())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un equipo con el nombre: " + dto.getNombre());
        }

        // Buscar la liga
        Liga liga = ligaRepository.findById(dto.getLigaId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Liga no encontrada con ID: " + dto.getLigaId()));

        // Crear el equipo
        Equipo equipo = new Equipo();
        equipo.setNombre(dto.getNombre());
        equipo.setNombreEstadio(dto.getNombreEstadio());
        equipo.setCiudad(dto.getCiudad());
        equipo.setAñoFundacion(dto.getAñoFundacion());
        equipo.setEscudoUrl(dto.getEscudoUrl());
        equipo.setLiga(liga);

        Equipo saved = equipoRepository.save(equipo);
        log.info("Equipo creado con ID: {}", saved.getId());

        return EquipoRequest.fromEntity(saved);
    }

    // Obtener equipo por ID
    @Transactional(readOnly = true)
    public EquipoRequest obtenerEquipoPorId(Long id) {
        Equipo equipo = equipoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + id));
        return EquipoRequest.fromEntity(equipo);
    }

    // Obtener equipo por nombre
    @Transactional(readOnly = true)
    public EquipoRequest obtenerEquipoPorNombre(String nombre) {
        Equipo equipo = equipoRepository.findByNombre(nombre)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con nombre: " + nombre));
        return EquipoRequest.fromEntity(equipo);
    }

    // Listar todos los equipos
    @Transactional(readOnly = true)
    public List<EquipoRequest> listarTodosEquipos() {
        return EquipoRequest.fromEntityList(equipoRepository.findAll());
    }

    // Listar equipos por liga
    @Transactional(readOnly = true)
    public List<EquipoRequest> listarEquiposPorLiga(Long ligaId) {
        return EquipoRequest.fromEntityList(equipoRepository.findByLigaId(ligaId));
    }

    // Listar equipos sin entrenador
    @Transactional(readOnly = true)
    public List<EquipoRequest> listarEquiposSinEntrenador() {
        return EquipoRequest.fromEntityList(equipoRepository.findEquiposSinEntrenador());
    }

    // Actualizar equipo
    @Transactional
    public EquipoRequest actualizarEquipo(Long id, ActualizarEquipoDTO dto) {
        log.info("Actualizando equipo con ID: {}", id);

        Equipo equipo = equipoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + id));

        if (dto.getNombre() != null && !dto.getNombre().isEmpty()) {
            if (!dto.getNombre().equals(equipo.getNombre()) &&
                    equipoRepository.existsByNombre(dto.getNombre())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Ya existe un equipo con el nombre: " + dto.getNombre());
            }
            equipo.setNombre(dto.getNombre());
        }

        if (dto.getNombreEstadio() != null) {
            equipo.setNombreEstadio(dto.getNombreEstadio());
        }

        if (dto.getCiudad() != null) {
            equipo.setCiudad(dto.getCiudad());
        }

        if (dto.getAñoFundacion() > 0) {
            equipo.setAñoFundacion(dto.getAñoFundacion());
        }

        if (dto.getEscudoUrl() != null) {
            equipo.setEscudoUrl(dto.getEscudoUrl());
        }

        if (dto.getLigaId() != null) {
            Liga liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Liga no encontrada con ID: " + dto.getLigaId()));
            equipo.setLiga(liga);
        }

        Equipo updated = equipoRepository.save(equipo);
        log.info("Equipo actualizado: {}", updated.getNombre());

        return EquipoRequest.fromEntity(updated);
    }

    // Eliminar equipo
    @Transactional
    public void eliminarEquipo(Long id) {
        log.info("Eliminando equipo con ID: {}", id);

        if (!equipoRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Equipo no encontrado con ID: " + id);
        }

        equipoRepository.deleteById(id);
        log.info("Equipo eliminado con ID: {}", id);
    }

    // Obtener número de jugadores
    @Transactional(readOnly = true)
    public int contarJugadores(Long equipoId) {
        return equipoRepository.countJugadoresByEquipoId(equipoId);
    }
}