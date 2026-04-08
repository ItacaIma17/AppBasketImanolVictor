package Aplicacion.Services;

import Dominio.Entity.Liga;
import Dominio.Repositorys.LigaRepository;
import Presentacion.DTOS.Liga.LigaRequest;
import Presentacion.DTOS.Liga.LigaResponse;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LigaService {

    private final LigaRepository ligaRepository;

    @Transactional
    public LigaResponse crearLiga(LigaRequest dto) {
        if (ligaRepository.existsByNombreLiga(dto.getNombreLiga()))
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe una liga con ese nombre");

        Liga liga = new Liga();
        liga.setNombreLiga(dto.getNombreLiga());
        ligaRepository.save(liga);
        return toResponse(liga);
    }

    public List<LigaResponse> listarLigas() {
        return ligaRepository.findAll()
                .stream().map(this::toResponse)
                .collect(Collectors.toList());
    }

    public LigaResponse obtenerLiga(Long id) {
        Liga liga = ligaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Liga no encontrada"));
        return toResponse(liga);
    }

    @Transactional
    public LigaResponse actualizarLiga(Long id, LigaRequest dto) {
        Liga liga = ligaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Liga no encontrada"));
        liga.setNombreLiga(dto.getNombreLiga());
        return toResponse(ligaRepository.save(liga));
    }

    @Transactional
    public void eliminarLiga(Long id) {
        if (!ligaRepository.existsById(id))
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Liga no encontrada");
        ligaRepository.deleteById(id);
    }

    private LigaResponse toResponse(Liga liga) {
        LigaResponse r = new LigaResponse();
        r.setId(liga.getId());
        r.setNombreLiga(liga.getNombreLiga());
        r.setTotalEquipos(liga.getEquipos().size());
        r.setEquipos(liga.getEquipos().stream()
                .map(e -> e.getNombre())
                .collect(Collectors.toList()));
        return r;
    }
}