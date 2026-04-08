package Aplicacion.Services;

import Dominio.Entity.Arbitro;
import Dominio.Repositorys.ArbitroRepository;
import Presentacion.DTOS.Usuarios.Register.RegistroArbitroDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Slf4j
@Service
@RequiredArgsConstructor
public class ArbitroService {

    private final ArbitroRepository arbitroRepository;

    @Transactional
    public void crearDesdeRegistro(RegistroArbitroDTO dto, Dominio.Entity.Usuario usuario) {
        log.info("Creando árbitro desde registro para email: {}", dto.getEmail());

        // Validaciones específicas
        if (arbitroRepository.existsByEmail(dto.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe un árbitro con este email");
        }
        if (arbitroRepository.existsByUsername(dto.getUsername())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe un árbitro con este username");
        }
        if (arbitroRepository.existsByCodigoArbitro(dto.getCodigoArbitro())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El código de árbitro ya está en uso");
        }

        Arbitro arbitro = new Arbitro();
        arbitro.setNombre(dto.getNombre());
        arbitro.setApellidos(dto.getApellidos());
        arbitro.setUsername(dto.getUsername());
        arbitro.setEmail(dto.getEmail());
        arbitro.setPassword(usuario.getPassword());
        arbitro.setCodigoArbitro(dto.getCodigoArbitro());
        arbitro.setRole(dto.getRol());
        arbitro.setVerificado(false);

        arbitroRepository.save(arbitro);
        log.info("Árbitro creado con ID: {}", arbitro.getId());
    }

    @Transactional
    public void marcarComoVerificado(String email) {
        arbitroRepository.findByEmail(email).ifPresent(arbitro -> {
            arbitro.setVerificado(true);
            arbitroRepository.save(arbitro);
            log.info("Árbitro marcado como verificado: {}", email);
        });
    }

    @Transactional
    public void actualizarPassword(String email, String nuevaPasswordEncriptada) {
        arbitroRepository.findByEmail(email).ifPresent(arbitro -> {
            arbitro.setPassword(nuevaPasswordEncriptada);
            arbitroRepository.save(arbitro);
        });
    }

    public Long obtenerIdPorEmail(String email) {
        return arbitroRepository.findByEmail(email)
                .map(Arbitro::getId)
                .orElse(null);
    }

    // Métodos específicos de negocio para árbitros
    @Transactional(readOnly = true)
    public Arbitro obtenerPorCodigo(String codigoArbitro) {
        return arbitroRepository.findByCodigoArbitro(codigoArbitro)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Árbitro no encontrado"));
    }
}