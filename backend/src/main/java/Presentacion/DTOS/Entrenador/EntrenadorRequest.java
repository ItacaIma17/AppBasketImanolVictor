// Presentacion/DTOS/Entrenador/EntrenadorRequest.java
package Presentacion.DTOS.Entrenador;

import Dominio.Entity.Entrenador;
import lombok.Data;

import java.util.List;
import java.util.stream.Collectors;

@Data
public class EntrenadorRequest {
    private Long id;
    private String nombre;
    private String apellido;
    private String nombreCompleto;
    private String username;
    private String email;
    private int edad;
    private String codigoEntrenador;
    private String telefono;
    private String experiencia;
    private boolean verificado;
    private Long equipoId;
    private String nombreEquipo;

    public EntrenadorRequest() {}

    public static EntrenadorRequest fromEntity(Entrenador entrenador) {
        EntrenadorRequest dto = new EntrenadorRequest();
        dto.setId(entrenador.getId());
        dto.setNombre(entrenador.getNombre());
        dto.setApellido(entrenador.getApellido());
        dto.setNombreCompleto(entrenador.getNombreCompleto());
        dto.setUsername(entrenador.getUsername());
        dto.setEmail(entrenador.getEmail());
        dto.setEdad(entrenador.getEdad());
        dto.setCodigoEntrenador(entrenador.getCodigoEntrenador());
        dto.setTelefono(entrenador.getTelefono());
        dto.setExperiencia(entrenador.getExperiencia());
        dto.setVerificado(entrenador.isVerificado());

        if (entrenador.getEquipo() != null) {
            dto.setEquipoId(entrenador.getEquipo().getId());
            dto.setNombreEquipo(entrenador.getEquipo().getNombre());
        }

        return dto;
    }

    public static List<EntrenadorRequest> fromEntityList(List<Entrenador> entrenadores) {
        return entrenadores.stream()
                .map(EntrenadorRequest::fromEntity)
                .collect(Collectors.toList());
    }
}