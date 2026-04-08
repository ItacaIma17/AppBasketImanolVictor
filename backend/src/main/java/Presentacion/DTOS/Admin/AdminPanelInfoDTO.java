    package Presentacion.DTOS.Admin;

    import lombok.Data;
    import java.util.List;

    @Data
    public class AdminPanelInfoDTO {
        private int totalUsuarios;
        private int totalJugadores;
        private int totalEntrenadores;
        private int totalArbitros;
        private int totalEquipos;
        private int totalLigas;
        private int totalPartidos;
        private int partidosProgramados;
        private int partidosFinalizados;
        private int usuariosBloqueados;
        private int usuariosPendientesVerificacion;
        private List<String> ultimosRegistros;
    }