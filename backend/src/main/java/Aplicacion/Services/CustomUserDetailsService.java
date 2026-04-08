package Aplicacion.Services;

import Dominio.Entity.Usuario;
import Dominio.Repositorys.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import Dominio.Entity.Usuario;



@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Usuario usuario = usuarioRepository.findByUsername(username);
        if (usuario == null) {
            throw new UsernameNotFoundException("Usuario no encontrado con username: " + username);
        }

        // Convert your Usuario entity to a UserDetails object
        return User.builder()
                .username(usuario.getEmail())
                .password(usuario.getPassword()) // Password is already encoded
                .roles(usuario.getRole() != null ? usuario.getRole().name() : "USER")
                .build();
    }
}
