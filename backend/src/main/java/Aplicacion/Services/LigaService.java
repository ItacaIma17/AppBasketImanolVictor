package Aplicacion.Services;

import Dominio.Entity.Liga;
import Dominio.Repositorys.LigaRepository;
import Presentacion.DTOS.Liga.LigaRequest;
import Presentacion.DTOS.Liga.LigaResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class LigaService {

    private final LigaRepository ligaRepository;

    @Transactional
    public LigaResponse crearLiga(LigaRequest dto) {
        log.info("Creando liga: {}", dto.getNombreLiga());

        if (ligaRepository.existsByNombreLiga(dto.getNombreLiga())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe una liga con ese nombre");
        }

        Liga liga = dto.toEntity();
        Liga saved = ligaRepository.save(liga);
        log.info("Liga creada con ID: {}", saved.getId());

        return LigaResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<LigaResponse> listarTodasLigas() {
        return ligaRepository.findAll().stream()
                .map(LigaResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public LigaResponse obtenerLigaPorId(Long id) {
        Liga liga = ligaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Liga no encontrada"));
        return LigaResponse.fromEntity(liga);
    }

    @Transactional(readOnly = true)
    public LigaResponse obtenerLigaPorNombre(String nombre) {
        Liga liga = ligaRepository.findByNombreLiga(nombre)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Liga no encontrada"));
        return LigaResponse.fromEntity(liga);
    }

    @Transactional
    public LigaResponse actualizarLiga(Long id, LigaRequest dto) {
        Liga liga = ligaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Liga no encontrada"));

        liga.setNombreLiga(dto.getNombreLiga());
        liga.setNumeroEquipos(dto.getNumeroEquipos());

        Liga updated = ligaRepository.save(liga);
        log.info("Liga actualizada: {}", updated.getNombreLiga());

        return LigaResponse.fromEntity(updated);
    }

    @Transactional
    public void eliminarLiga(Long id) {
        if (!ligaRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Liga no encontrada");
        }
        ligaRepository.deleteById(id);
        log.info("Liga eliminada con ID: {}", id);
    }
}