package Presentacion.DTOS.Equipo;

import Dominio.Entity.Equipo;
import lombok.Data;

import java.util.List;
import java.util.stream.Collectors;

@Data
public class EquipoRequest {
    private Long id;
    private String nombre;
    private String nombreEstadio;
    private String ciudad;
    private int añoFundacion;
    private String escudoUrl;
    private Long ligaId;
    private String nombreLiga;
    private Long entrenadorId;
    private String nombreEntrenador;
    private int numeroJugadores;

    public EquipoRequest() {}

    public static EquipoRequest fromEntity(Equipo equipo) {
        EquipoRequest dto = new EquipoRequest();
        dto.setId(equipo.getId());
        dto.setNombre(equipo.getNombre());
        dto.setNombreEstadio(equipo.getNombreEstadio());
        dto.setCiudad(equipo.getCiudad());
        dto.setAñoFundacion(equipo.getAñoFundacion());
        dto.setEscudoUrl(equipo.getEscudoUrl());

        if (equipo.getLiga() != null) {
            dto.setLigaId(equipo.getLiga().getId());
            dto.setNombreLiga(equipo.getLiga().getNombreLiga());
        }

        if (equipo.getEntrenador() != null) {
            dto.setEntrenadorId(equipo.getEntrenador().getId());
            dto.setNombreEntrenador(equipo.getEntrenador().getNombreCompleto());
        }

        dto.setNumeroJugadores(equipo.getJugadores() != null ? equipo.getJugadores().size() : 0);

        return dto;
    }

    public static List<EquipoRequest> fromEntityList(List<Equipo> equipos) {
        return equipos.stream()
                .map(EquipoRequest::fromEntity)
                .collect(Collectors.toList());
    }
}