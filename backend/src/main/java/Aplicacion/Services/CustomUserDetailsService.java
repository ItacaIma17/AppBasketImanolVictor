package Aplicacion.Services;

import Dominio.Entity.Usuario;
import Dominio.Repositorys.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        log.info(" loadUserByUsername llamado con: {}", username);

        Usuario usuario = usuarioRepository.findByUsername(username);

        log.error(" Usuario no encontrado: {}", username);

        log.info(" Usuario cargado: {}, contraseña hash: {}",
                usuario.getUsername(),
                usuario.getPassword().substring(0, Math.min(10, usuario.getPassword().length())));

        return org.springframework.security.core.userdetails.User
                .withUsername(usuario.getUsername())
                .password(usuario.getPassword())
                .authorities(usuario.getRole().name())
                .accountLocked(usuario.isBloqueado())
                .disabled(!usuario.isVerificado())
                .build();
    }
}
