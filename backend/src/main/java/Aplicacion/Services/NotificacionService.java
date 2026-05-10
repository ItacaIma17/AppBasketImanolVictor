package Aplicacion.Services;

import Dominio.Entity.Partido;
import Dominio.Entity.Usuario;
import Dominio.Repositorys.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

@Slf4j
@Service
public class NotificacionService {

    @Autowired
    private EmailService emailService;

    @Autowired
    private UserRepository userRepository;

    private static final DateTimeFormatter FORMATO_FECHA =
            DateTimeFormatter.ofPattern("EEEE dd 'de' MMMM 'a las' HH:mm", new Locale("es", "ES"));

    public void notificarPartidoCreado(Partido partido) {
        if (partido == null) return;

        String fecha = partido.getFecha() != null
                ? partido.getFecha().format(FORMATO_FECHA)
                : "fecha por confirmar";

        String asunto = " Nuevo partido programado - " +
                partido.getEquipoLocal().getNombre() + " vs " +
                partido.getEquipoVisitante().getNombre();

        String cuerpo = construirCuerpoPartido(partido, fecha,
                "Se ha programado un nuevo partido en la Federación Aragonesa de Baloncesto.");

        notificarEquipo(partido, asunto, cuerpo);
    }

    public void enviarNotificacion(String email, String asunto, String mensaje) {
        try {
            String cuerpoHtml = emailTemplate(asunto, mensaje);
            emailService.sendHtmlMail(email, asunto, cuerpoHtml);
            log.info(" Notificación enviada a: {}", email);
        } catch (Exception e) {
            log.error(" Error enviando notificación a {}: {}", email, e.getMessage());
        }
    }

    public void enviarNotificacionTexto(String email, String asunto, String mensaje) {
        try {
            emailService.sendTextMail(email, asunto, mensaje);
            log.info(" Notificación texto enviada a: {}", email);
        } catch (Exception e) {
            log.error(" Error enviando notificación a {}: {}", email, e.getMessage());
        }
    }

    public void enviarComunicadoMasivo(List<String> emails, String asunto, String mensaje) {
        int enviados = 0;
        int fallidos = 0;

        for (String email : emails) {
            try {
                String cuerpoHtml = emailTemplate(asunto, mensaje);
                emailService.sendHtmlMail(email, asunto, cuerpoHtml);
                enviados++;
            } catch (Exception e) {
                fallidos++;
                log.error(" Error enviando a {}: {}", email, e.getMessage());
            }
        }

        log.info(" Comunicado masivo enviado - Exitosos: {}, Fallidos: {}", enviados, fallidos);
    }

    public void notificarResultadoPartido(Partido partido) {
        if (partido == null) return;

        String asunto = " Resultado: " +
                partido.getEquipoLocal().getNombre() + " " +
                partido.getResultadoLocal() + " - " +
                partido.getResultadoVisitante() + " " +
                partido.getEquipoVisitante().getNombre();

        String cuerpo = "El partido entre <strong>" +
                partido.getEquipoLocal().getNombre() + "</strong> y <strong>" +
                partido.getEquipoVisitante().getNombre() + "</strong> ha finalizado.<br><br>" +
                "<strong>Resultado final:</strong><br>" +
                partido.getEquipoLocal().getNombre() + ": " + partido.getResultadoLocal() + " pts<br>" +
                partido.getEquipoVisitante().getNombre() + ": " + partido.getResultadoVisitante() + " pts<br><br>" +
                "Consulta las estadísticas detalladas en la aplicación FAB.";

        notificarEquipo(partido, asunto, cuerpo);

        if (partido.getArbitro() != null && partido.getArbitro().getEmail() != null) {
            String cuerpoArbitro = "Has registrado el resultado del partido entre <strong>" +
                    partido.getEquipoLocal().getNombre() + "</strong> y <strong>" +
                    partido.getEquipoVisitante().getNombre() + "</strong>.<br><br>" +
                    "<strong>Resultado final:</strong><br>" +
                    partido.getEquipoLocal().getNombre() + ": " + partido.getResultadoLocal() + " pts<br>" +
                    partido.getEquipoVisitante().getNombre() + ": " + partido.getResultadoVisitante() + " pts";

            enviarNotificacion(partido.getArbitro().getEmail(), asunto, cuerpoArbitro);
        }
    }

    public void notificarArbitroAsignado(Partido partido) {
        if (partido == null || partido.getArbitro() == null) return;
        if (partido.getArbitro().getEmail() == null) return;

        String fecha = partido.getFecha() != null
                ? partido.getFecha().format(FORMATO_FECHA)
                : "fecha por confirmar";

        String asunto = " Nueva designación - " +
                partido.getEquipoLocal().getNombre() + " vs " +
                partido.getEquipoVisitante().getNombre();

        String cuerpo = "Has sido designado como árbitro para el partido:<br><br>" +
                "<strong>" + partido.getEquipoLocal().getNombre() + "</strong> vs " +
                "<strong>" + partido.getEquipoVisitante().getNombre() + "</strong><br><br>" +
                " <strong>Fecha:</strong> " + fecha + "<br>" +
                " <strong>Pabellón:</strong> " + (partido.getPabellon() != null ? partido.getPabellon() : "por confirmar") + "<br>" +
                " <strong>Ubicación:</strong> " + (partido.getUbicacion() != null ? partido.getUbicacion() : "por confirmar") + "<br><br>" +
                "Recuerda validar las alineaciones antes del partido.";

        enviarNotificacion(partido.getArbitro().getEmail(), asunto, cuerpo);
    }

    public void notificarAlineacionConfirmada(Partido partido, String emailEntrenador, String nombreEquipo) {
        if (emailEntrenador == null) return;

        String asunto = " Alineación confirmada - " + nombreEquipo;
        String cuerpo = "La alineación de <strong>" + nombreEquipo + "</strong> ha sido confirmada " +
                "por el árbitro para el partido del " +
                (partido.getFecha() != null ? partido.getFecha().format(FORMATO_FECHA) : "próximo partido") + ".<br><br>" +
                "Ya puedes ver la alineación del equipo rival en la aplicación.";

        enviarNotificacion(emailEntrenador, asunto, cuerpo);
    }

    public void notificarAlineacionRechazada(Partido partido, String emailEntrenador, String nombreEquipo, String motivo) {
        if (emailEntrenador == null) return;

        String asunto = " Alineación requiere cambios - " + nombreEquipo;
        String cuerpo = "La alineación de <strong>" + nombreEquipo + "</strong> requiere modificaciones.<br><br>" +
                "<strong>Motivo:</strong> " + motivo + "<br><br>" +
                "Por favor, revisa y vuelve a enviar la alineación antes del partido del " +
                (partido.getFecha() != null ? partido.getFecha().format(FORMATO_FECHA) : "próximo partido");

        enviarNotificacion(emailEntrenador, asunto, cuerpo);
    }

    public void notificarActaSubida(Partido partido) {
        if (partido == null) return;

        String asunto = " Acta disponible - " +
                partido.getEquipoLocal().getNombre() + " vs " +
                partido.getEquipoVisitante().getNombre();

        String cuerpo = "El acta del partido entre <strong>" +
                partido.getEquipoLocal().getNombre() + "</strong> y <strong>" +
                partido.getEquipoVisitante().getNombre() + "</strong> ya está disponible.<br><br>" +
                "Puedes consultarla desde la aplicación en la sección de Actas y Estadísticas.";

        notificarEquipo(partido, asunto, cuerpo);

        if (partido.getArbitro() != null && partido.getArbitro().getEmail() != null) {
            String cuerpoArbitro = "Has subido el acta del partido entre <strong>" +
                    partido.getEquipoLocal().getNombre() + "</strong> y <strong>" +
                    partido.getEquipoVisitante().getNombre() + "</strong>.<br><br>" +
                    "El acta ha sido registrada correctamente en el sistema.";

            enviarNotificacion(partido.getArbitro().getEmail(), asunto, cuerpoArbitro);
        }
    }

    public void notificarComunicadoGeneral(String asunto, String mensaje) {
        List<Usuario> usuarios = userRepository.findAll();
        int enviados = 0;

        for (Usuario usuario : usuarios) {
            if (usuario.getEmail() != null && !usuario.getEmail().isEmpty()) {
                try {
                    String cuerpo = "<p>" + mensaje + "</p><br>" +
                            "<p style='color: #666; font-size: 12px;'>" +
                            "Este es un comunicado oficial de la Federación Aragonesa de Baloncesto.</p>";
                    enviarNotificacion(usuario.getEmail(), asunto, cuerpo);
                    enviados++;
                } catch (Exception e) {
                    log.error("Error enviando a {}: {}", usuario.getEmail(), e.getMessage());
                }
            }
        }

        log.info(" Comunicado general '{}' enviado a {} usuarios", asunto, enviados);
    }

    private void notificarEquipo(Partido partido, String asunto, String cuerpo) {
        String cuerpoHtml = emailTemplate(asunto, cuerpo);

        if (partido.getEquipoLocal() != null && partido.getEquipoLocal().getJugadores() != null) {
            partido.getEquipoLocal().getJugadores().forEach(j -> {
                if (j.getEmail() != null && !j.getEmail().isEmpty()) {
                    try {
                        emailService.sendHtmlMail(j.getEmail(), asunto, cuerpoHtml);
                        log.debug("Notificación enviada a jugador: {}", j.getEmail());
                    } catch (Exception e) {
                        log.error("Error notificando a jugador {}: {}", j.getEmail(), e.getMessage());
                    }
                }
            });
        }

        if (partido.getEquipoVisitante() != null && partido.getEquipoVisitante().getJugadores() != null) {
            partido.getEquipoVisitante().getJugadores().forEach(j -> {
                if (j.getEmail() != null && !j.getEmail().isEmpty()) {
                    try {
                        emailService.sendHtmlMail(j.getEmail(), asunto, cuerpoHtml);
                        log.debug("Notificación enviada a jugador: {}", j.getEmail());
                    } catch (Exception e) {
                        log.error("Error notificando a jugador {}: {}", j.getEmail(), e.getMessage());
                    }
                }
            });
        }

        if (partido.getEquipoLocal() != null && partido.getEquipoLocal().getEntrenador() != null) {
            String email = partido.getEquipoLocal().getEntrenador().getEmail();
            if (email != null && !email.isEmpty()) {
                enviarNotificacion(email, asunto, cuerpo);
            }
        }

        if (partido.getEquipoVisitante() != null && partido.getEquipoVisitante().getEntrenador() != null) {
            String email = partido.getEquipoVisitante().getEntrenador().getEmail();
            if (email != null && !email.isEmpty()) {
                enviarNotificacion(email, asunto, cuerpo);
            }
        }
    }

    private String construirCuerpoPartido(Partido partido, String fecha, String intro) {
        return intro + "<br><br>" +
                "<strong>" + partido.getEquipoLocal().getNombre() + "</strong> vs <strong>" +
                partido.getEquipoVisitante().getNombre() + "</strong><br><br>" +
                " <strong>Fecha:</strong> " + fecha + "<br>" +
                " <strong>Pabellón:</strong> " + (partido.getPabellon() != null ? partido.getPabellon() : "por confirmar") + "<br>" +
                " <strong>Dirección:</strong> " + (partido.getUbicacion() != null ? partido.getUbicacion() : "por confirmar") + "<br><br>" +
                "Puedes consultar todos los detalles en la aplicación FAB.";
    }

    private String emailTemplate(String titulo, String contenido) {
        return "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "<meta charset='UTF-8'>" +
                "<style>" +
                "body { font-family: 'Roboto', Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 20px; }" +
                ".container { max-width: 600px; margin: 0 auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }" +
                ".header { background: linear-gradient(135deg, #C4161C, #F28C00); padding: 24px; text-align: center; }" +
                ".header h1 { color: white; margin: 0; font-size: 22px; }" +
                ".header p { color: rgba(255,255,255,0.9); margin: 8px 0 0; font-size: 12px; }" +
                ".content { padding: 28px; }" +
                ".content h2 { color: #C4161C; margin-top: 0; font-size: 20px; }" +
                ".content p { color: #333; line-height: 1.6; margin: 0 0 16px; }" +
                ".button { display: inline-block; background: #F28C00; color: white; text-decoration: none; padding: 10px 24px; border-radius: 25px; margin-top: 16px; }" +
                ".footer { background: #f9f9f9; padding: 16px; text-align: center; font-size: 11px; color: #999; }" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class='container'>" +
                "<div class='header'>" +
                "<h1> Federación Aragonesa de Basket</h1>" +
                "<p>Oficial</p>" +
                "</div>" +
                "<div class='content'>" +
                "<h2>" + titulo + "</h2>" +
                "<p>" + contenido + "</p>" +
                "</div>" +
                "<div class='footer'>" +
                "© 2026 Federación Aragonesa de Basket · Este es un mensaje automático<br>" +
                "Por favor, no responder a este email." +
                "</div>" +
                "</div>" +
                "</body>" +
                "</html>";
    }
}
