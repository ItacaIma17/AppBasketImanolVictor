package Aplicacion.Services;

import Presentacion.DTOS.Admin.ComunicadoAdminDTO;
import Presentacion.DTOS.Partido.RecordatorioPartidoDTO;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    public enum TipoEmail {
        CODIGO_VERIFICACION,
        CUENTA_BLOQUEADA,
        CUENTA_DESBLOQUEADA,
        ASIGNACION_ENTRENADOR,
        ASIGNACION_ARBITRO,
        SANCION_JUGADOR,
        NOTIFICACION_SANCION_ENTRENADOR,
        RECORDATORIO_PARTIDO,
        COMUNICADO_GENERAL
    }

    public void sendHtmlMail(String to, String subject, String htmlContent) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlContent, true);

        mailSender.send(message);
        log.info(" Email HTML enviado a: {} - Asunto: {}", to, subject);
    }

    public void sendTextMail(String to, String subject, String textContent) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");

        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(textContent, false);

        mailSender.send(message);
        log.info(" Email texto enviado a: {} - Asunto: {}", to, subject);
    }

    public void enviarCodigoVerificacion(String to, String codigo) throws MessagingException {
        String subject = "Código de verificación - Federación Aragonesa de Baloncesto";
        String content = String.format("""
            <h2>Bienvenido a la Federación Aragonesa de Baloncesto</h2>
            <p>Tu código de verificación es: <strong style="font-size: 24px;">%s</strong></p>
            <p>Este código expirará en 10 minutos.</p>
            <p>Si no has solicitado este registro, ignora este mensaje.</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, codigo);
        sendHtmlMail(to, subject, content);
    }

    public void enviarCuentaBloqueada(String to, String nombre) throws MessagingException {
        String subject = "Cuenta suspendida - Federación Aragonesa de Baloncesto";
        String content = String.format("""
            <h2>Hola, %s</h2>
            <p>Tu cuenta ha sido <strong style="color: red;">suspendida temporalmente</strong>
               por la Federación Aragonesa de Baloncesto.</p>
            <p>Si crees que es un error, responde a este email o contacta con nosotros.</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, nombre);
        sendHtmlMail(to, subject, content);
    }

    public void enviarCuentaDesbloqueada(String to, String nombre) throws MessagingException {
        String subject = "Cuenta reactivada - Federación Aragonesa de Baloncesto";
        String content = String.format("""
            <h2>Hola, %s</h2>
            <p>Tu cuenta ha sido <strong style="color: green;">reactivada</strong>.</p>
            <p>Ya puedes volver a acceder a la app con normalidad.</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, nombre);
        sendHtmlMail(to, subject, content);
    }

    public void enviarAsignacionEquipoEntrenador(String to, String nombre, String equipoNombre) throws MessagingException {
        String subject = "Asignación de equipo - Federación Aragonesa de Baloncesto";
        String content = String.format("""
            <h2>Hola, %s</h2>
            <p>Has sido asignado/a como entrenador/a del equipo
               <strong style="color: orange;">%s</strong>.</p>
            <p>Ya puedes acceder a los datos del equipo, subir alineaciones y ver el calendario desde la app.</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, nombre, equipoNombre);
        sendHtmlMail(to, subject, content);
    }

    public void enviarAsignacionPartidoArbitro(String to, String nombre, String equipoLocal,
                                               String equipoVisitante, LocalDateTime fecha,
                                               String pabellon) throws MessagingException {
        String subject = "Partido asignado - Federación Aragonesa de Baloncesto";
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        String fechaFormateada = fecha.format(formatter);

        String content = String.format("""
            <h2>Hola, %s</h2>
            <p>Se te ha asignado el siguiente partido:</p>
            <table border="1" cellpadding="8" style="border-collapse: collapse;">
                <tr><th style="background: #f0f0f0;">Local</th><td>%s</td></tr>
                <tr><th style="background: #f0f0f0;">Visitante</th><td>%s</td></tr>
                <tr><th style="background: #f0f0f0;">Fecha y hora</th><td>%s</td></tr>
                <tr><th style="background: #f0f0f0;">Pabellón</th><td>%s</td></tr>
            </table>
            <p>Recuerda revisar los equipos antes del partido y confirmar las alineaciones.</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, nombre, equipoLocal, equipoVisitante, fechaFormateada, pabellon);
        sendHtmlMail(to, subject, content);
    }

    public void enviarSancion(String to, String nombre, int partidos, String motivo) throws MessagingException {
        String subject = "Notificación de sanción - Federación Aragonesa de Baloncesto";
        String content = String.format("""
            <h2>Hola, %s</h2>
            <p>La Federación Aragonesa de Baloncesto te comunica que has recibido una
               <strong style="color: red;">sanción de %d partido(s)</strong>.</p>
            <p><strong>Motivo:</strong> %s</p>
            <p>Si deseas presentar alegaciones, responde a este email en un plazo de 48 horas.</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, nombre, partidos, motivo);
        sendHtmlMail(to, subject, content);
    }

    public void enviarNotificacionSancionEntrenador(String to, String nombreEntrenador,
                                                    String nombreJugador, int partidos,
                                                    String motivo) throws MessagingException {
        String subject = "Sanción a jugador de tu equipo - Federación Aragonesa de Baloncesto";
        String content = String.format("""
            <h2>Hola, %s</h2>
            <p>Te informamos de que el jugador <strong>%s</strong> de tu equipo ha recibido una sanción de
               <strong>%d partido(s)</strong>.</p>
            <p><strong>Motivo:</strong> %s</p>
            <p>Tenlo en cuenta para la próxima convocatoria.</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, nombreEntrenador, nombreJugador, partidos, motivo);
        sendHtmlMail(to, subject, content);
    }

    public void enviarInscripcionEquipo(String to, String nombre, String equipoNombre, String liga)
            throws MessagingException {
        String subject = "Inscripción en equipo - Federación Aragonesa de Baloncesto";
        String content = String.format("""
            <h2>¡Bienvenido a tu nuevo equipo, %s!</h2>
            <p>Has sido inscrito oficialmente en el equipo <strong>%s</strong>.</p>
            <p><strong>Liga:</strong> %s</p>
            <p>Ya puedes acceder a la aplicación para ver la información de tu equipo,
               calendario de partidos y estadísticas.</p>
            <p>Si tienes alguna duda, contacta con tu entrenador o con la Federación.</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, nombre, equipoNombre, liga);
        sendHtmlMail(to, subject, content);
    }

    public void enviarRecordatorioPartido(RecordatorioPartidoDTO dto) throws MessagingException {
        String subject = "Recordatorio de partido - Federación Aragonesa de Baloncesto";
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        String fechaFormateada = dto.getFecha().format(formatter);

        String content = String.format("""
            <h2>Hola, %s</h2>
            <p>Te recordamos que tienes partido próximamente:</p>
            <table border="1" cellpadding="8" style="border-collapse: collapse;">
                <tr><th style="background: #f0f0f0;">Rival</th><td>%s</td></tr>
                <tr><th style="background: #f0f0f0;">Fecha y hora</th><td>%s</td></tr>
                <tr><th style="background: #f0f0f0;">Pabellón</th><td>%s</td></tr>
                <tr><th style="background: #f0f0f0;">Dirección</th><td>%s</td></tr>
            </table>
            <p>¡Mucha suerte!</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, dto.getNombreUsuario(), dto.getNombreRival(),
                fechaFormateada, dto.getPabellon(), dto.getDireccionPabellon());
        sendHtmlMail(dto.getSendto(), subject, content);
    }

    public void enviarRecuperacionContrasena(String to, String nombre, String codigo) throws MessagingException {
        String subject = "Recuperación de contraseña - Federación Aragonesa de Baloncesto";
        String content = String.format("""
            <h2>Hola, %s</h2>
            <p>Has solicitado restablecer tu contraseña.</p>
            <p>Tu código de recuperación es: <strong style="font-size: 24px;">%s</strong></p>
            <p>Este código expirará en 15 minutos.</p>
            <p>Si no has solicitado este cambio, ignora este mensaje. Tu contraseña no será modificada.</p>
            <br>
            <p>Federación Aragonesa de Baloncesto</p>
            """, nombre, codigo);
        sendHtmlMail(to, subject, content);
    }

    public void enviarComunicado(String to, String asunto, String mensaje) throws MessagingException {
        String subject = asunto != null ? asunto : "Comunicado oficial - Federación Aragonesa de Baloncesto";
        String content = String.format("""
            <h2>Comunicado Oficial - Federación Aragonesa de Baloncesto</h2>
            <div style="background-color: #f5f5f5; padding: 20px; border-radius: 5px;">
                <p>%s</p>
            </div>
            <br>
            <p style="color: #666; font-size: 12px;">Este es un mensaje automático, por favor no responder a este email.</p>
            <p>Federación Aragonesa de Baloncesto</p>
            """, mensaje);
        sendHtmlMail(to, subject, content);
    }

    public void enviarEmail(TipoEmail tipo, Map<String, Object> parametros) throws MessagingException {
        String to = (String) parametros.get("to");
        String subject = obtenerAsunto(tipo);
        String contenido = construirContenido(tipo, parametros);
        sendHtmlMail(to, subject, contenido);
    }

    private String obtenerAsunto(TipoEmail tipo) {
        return switch (tipo) {
            case CODIGO_VERIFICACION -> "Código de verificación - Federación Aragonesa de Baloncesto";
            case CUENTA_BLOQUEADA -> "Cuenta suspendida - Federación Aragonesa de Baloncesto";
            case CUENTA_DESBLOQUEADA -> "Cuenta reactivada - Federación Aragonesa de Baloncesto";
            case ASIGNACION_ENTRENADOR -> "Asignación de equipo - Federación Aragonesa de Baloncesto";
            case ASIGNACION_ARBITRO -> "Partido asignado - Federación Aragonesa de Baloncesto";
            case SANCION_JUGADOR -> "Notificación de sanción - Federación Aragonesa de Baloncesto";
            case NOTIFICACION_SANCION_ENTRENADOR -> "Sanción a jugador de tu equipo - Federación Aragonesa de Baloncesto";
            case RECORDATORIO_PARTIDO -> "Recordatorio de partido - Federación Aragonesa de Baloncesto";
            case COMUNICADO_GENERAL -> "Comunicado oficial - Federación Aragonesa de Baloncesto";
        };
    }

    private String construirContenido(TipoEmail tipo, Map<String, Object> params) {
        return switch (tipo) {
            case CODIGO_VERIFICACION -> String.format("""
                <h2>Bienvenido a la Federación Aragonesa de Baloncesto</h2>
                <p>Tu código de verificación es: <strong style="font-size: 24px;">%s</strong></p>
                <p>Este código expirará en 10 minutos.</p>
                <p>Si no has solicitado este registro, ignora este mensaje.</p>
                """, params.get("codigo"));

            case CUENTA_BLOQUEADA -> String.format("""
                <h2>Hola, %s</h2>
                <p>Tu cuenta ha sido <strong style="color: red;">suspendida temporalmente</strong>
                   por la Federación Aragonesa de Baloncesto.</p>
                <p>Si crees que es un error, responde a este email o contacta con nosotros.</p>
                """, params.get("nombre"));

            case CUENTA_DESBLOQUEADA -> String.format("""
                <h2>Hola, %s</h2>
                <p>Tu cuenta ha sido <strong style="color: green;">reactivada</strong>.</p>
                <p>Ya puedes volver a acceder a la app con normalidad.</p>
                """, params.get("nombre"));

            case ASIGNACION_ENTRENADOR -> String.format("""
                <h2>Hola, %s</h2>
                <p>Has sido asignado/a como entrenador/a del equipo
                   <strong style="color: orange;">%s</strong>.</p>
                <p>Ya puedes acceder a los datos del equipo, subir alineaciones y ver el calendario desde la app.</p>
                """, params.get("nombre"), params.get("equipoNombre"));

            case ASIGNACION_ARBITRO -> {
                LocalDateTime fecha = (LocalDateTime) params.get("fecha");
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                yield String.format("""
                    <h2>Hola, %s</h2>
                    <p>Se te ha asignado el siguiente partido:</p>
                    <table border="1" cellpadding="8" style="border-collapse: collapse;">
                        <tr><th>Local</th><td>%s</td></tr>
                        <tr><th>Visitante</th><td>%s</td></tr>
                        <tr><th>Fecha</th><td>%s</td></tr>
                        <tr><th>Pabellón</th><td>%s</td></tr>
                    </table>
                    <p>Recuerda revisar los equipos antes del partido.</p>
                    """, params.get("nombre"), params.get("equipoLocal"),
                        params.get("equipoVisitante"), fecha.format(formatter),
                        params.get("pabellon"));
            }

            case SANCION_JUGADOR -> String.format("""
                <h2>Hola, %s</h2>
                <p>La Federación Aragonesa de Baloncesto te comunica que has recibido una
                   <strong style="color: red;">sanción de %d partido(s)</strong>.</p>
                <p><strong>Motivo:</strong> %s</p>
                <p>Si deseas presentar alegaciones, responde a este email en un plazo de 48 horas.</p>
                """, params.get("nombre"), params.get("partidos"), params.get("motivo"));

            case NOTIFICACION_SANCION_ENTRENADOR -> String.format("""
                <h2>Hola, %s</h2>
                <p>Te informamos de que el jugador <strong>%s</strong> de tu equipo ha recibido una sanción de
                   <strong>%d partido(s)</strong>.</p>
                <p><strong>Motivo:</strong> %s</p>
                <p>Tenlo en cuenta para la próxima convocatoria.</p>
                """, params.get("nombreEntrenador"), params.get("nombreJugador"),
                    params.get("partidos"), params.get("motivo"));

            case RECORDATORIO_PARTIDO -> {
                LocalDateTime fecha = (LocalDateTime) params.get("fecha");
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                yield String.format("""
                    <h2>Hola, %s</h2>
                    <p>Te recordamos que tienes partido próximamente:</p>
                    <table border="1" cellpadding="8" style="border-collapse: collapse;">
                        <tr><th>Rival</th><td>%s</td></tr>
                        <tr><th>Fecha y hora</th><td>%s</td></tr>
                        <tr><th>Pabellón</th><td>%s</td></tr>
                        <tr><th>Dirección</th><td>%s</td></tr>
                    </table>
                    <p>¡Mucha suerte!</p>
                    """, params.get("nombreUsuario"), params.get("nombreRival"),
                        fecha.format(formatter), params.get("pabellon"),
                        params.get("direccionPabellon"));
            }

            case COMUNICADO_GENERAL -> String.format("""
                <h2>Comunicado Oficial - Federación Aragonesa de Baloncesto</h2>
                <div style="background-color: #f5f5f5; padding: 20px; border-radius: 5px;">
                    <p>%s</p>
                </div>
                <p style="color: #666; font-size: 12px;">Este es un mensaje automático, por favor no responder a este email.</p>
                """, params.get("mensaje"));
        };
    }
}
