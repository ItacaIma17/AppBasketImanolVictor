package Aplicacion.Services;

import Dominio.Entity.Partido;
import Dominio.Entity.Usuario;
import Dominio.Repositorys.PartidoRepository;
import Dominio.Repositorys.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

@Slf4j
@Component
@RequiredArgsConstructor
public class PartidoReminderScheduler {

    private final PartidoRepository partidoRepository;
    private final UserRepository userRepository;
    private final NotificacionService notificacionService;

    private static final DateTimeFormatter FORMATO_FECHA =
            DateTimeFormatter.ofPattern("EEEE dd 'de' MMMM 'a las' HH:mm", new Locale("es", "ES"));

    @Scheduled(cron = "0 0 8 * * *")
    public void notificarPartidosHoy() {
        LocalDateTime inicioDia = LocalDate.now().atStartOfDay();
        LocalDateTime finDia = inicioDia.plusDays(1).minusSeconds(1);

        List<Partido> partidosHoy = partidoRepository.findPartidosEntreFechas(inicioDia, finDia);

        if (partidosHoy.isEmpty()) {
            log.info("No hay partidos hoy para notificar seguidores.");
            return;
        }

        log.info("Notificando seguidores para {} partido(s) de hoy.", partidosHoy.size());

        for (Partido partido : partidosHoy) {
            String fecha = partido.getFecha() != null
                    ? partido.getFecha().format(FORMATO_FECHA)
                    : "hoy";

            String asunto = "Hoy juega tu equipo - " +
                    partido.getEquipoLocal().getNombre() + " vs " +
                    partido.getEquipoVisitante().getNombre();

            String cuerpo = "¡Hoy hay partido!<br><br>" +
                    "<strong>" + partido.getEquipoLocal().getNombre() + "</strong> vs " +
                    "<strong>" + partido.getEquipoVisitante().getNombre() + "</strong><br><br>" +
                    " <strong>Fecha:</strong> " + fecha + "<br>" +
                    " <strong>Pabellón:</strong> " + (partido.getPabellon() != null ? partido.getPabellon() : "por confirmar") + "<br>" +
                    " <strong>Dirección:</strong> " + (partido.getUbicacion() != null ? partido.getUbicacion() : "por confirmar") + "<br><br>" +
                    "Sigue el partido en directo desde la aplicación FAB.";

            notificarSeguidoresAmbosEquipos(partido, asunto, cuerpo);
        }
    }

    private void notificarSeguidoresAmbosEquipos(Partido partido, String asunto, String cuerpo) {
        Set<String> emailsNotificados = new HashSet<>();

        if (partido.getEquipoLocal() != null) {
            List<Usuario> seguidores = userRepository.findSeguidoresByEquipoId(partido.getEquipoLocal().getId());
            for (Usuario u : seguidores) {
                if (u.getEmail() != null && !u.getEmail().isEmpty() && emailsNotificados.add(u.getEmail())) {
                    notificacionService.enviarNotificacion(u.getEmail(), asunto, cuerpo);
                }
            }
        }

        if (partido.getEquipoVisitante() != null) {
            List<Usuario> seguidores = userRepository.findSeguidoresByEquipoId(partido.getEquipoVisitante().getId());
            for (Usuario u : seguidores) {
                if (u.getEmail() != null && !u.getEmail().isEmpty() && emailsNotificados.add(u.getEmail())) {
                    notificacionService.enviarNotificacion(u.getEmail(), asunto, cuerpo);
                }
            }
        }

        log.info("Seguidores notificados para partido {}: {} emails enviados",
                partido.getId(), emailsNotificados.size());
    }
}