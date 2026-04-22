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

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;


    // Enum para tipos de email
    public enum TipoEmail {
        CODIGO_VERIFICACION,
        CUENTA_BLOQUEADA,
        CUENTA_DESBLOQUEADA,
        ASIGNACION_ENTRENADOR,
        ASIGNACION_ARBITRO,
        SANCION_JUGADOR,
        NOTIFICACION_SANCION_ENTRENADOR,
        RECORDATORIO_PARTIDO
    }

    // Método principal que procesa cualquier tipo de email
    public void enviarEmail(TipoEmail tipo, Map<String, Object> parametros) throws MessagingException {
        String to = (String) parametros.get("to");
        String subject = obtenerAsunto(tipo);
        String contenido = construirContenido(tipo, parametros);

        enviar(to, subject, contenido);
    }

    // Métodos específicos para cada caso (más limpios para el código cliente)
    public void enviarCodigoVerificacion(String to, String codigo) throws MessagingException {
        Map<String, Object> params = new HashMap<>();
        params.put("to", to);
        params.put("codigo", codigo);
        enviarEmail(TipoEmail.CODIGO_VERIFICACION, params);
    }

    public void enviarCuentaBloqueada(String to, String nombre) throws MessagingException {
        Map<String, Object> params = new HashMap<>();
        params.put("to", to);
        params.put("nombre", nombre);
        enviarEmail(TipoEmail.CUENTA_BLOQUEADA, params);
    }

    public void enviarCuentaDesbloqueada(String to, String nombre) throws MessagingException {
        Map<String, Object> params = new HashMap<>();
        params.put("to", to);
        params.put("nombre", nombre);
        enviarEmail(TipoEmail.CUENTA_DESBLOQUEADA, params);
    }

    public void enviarAsignacionEquipoEntrenador(String to, String nombre, String equipoNombre) throws MessagingException {
        Map<String, Object> params = new HashMap<>();
        params.put("to", to);
        params.put("nombre", nombre);
        params.put("equipoNombre", equipoNombre);
        enviarEmail(TipoEmail.ASIGNACION_ENTRENADOR, params);
    }

    public void enviarAsignacionPartidoArbitro(String to, String nombre, String equipoLocal,
                                               String equipoVisitante, LocalDate fecha,
                                               String pabellon) throws MessagingException {
        Map<String, Object> params = new HashMap<>();
        params.put("to", to);
        params.put("nombre", nombre);
        params.put("equipoLocal", equipoLocal);
        params.put("equipoVisitante", equipoVisitante);
        params.put("fecha", fecha);
        params.put("pabellon", pabellon);
        enviarEmail(TipoEmail.ASIGNACION_ARBITRO, params);
    }

    public void enviarSancion(String to, String nombre, int partidos, String motivo) throws MessagingException {
        Map<String, Object> params = new HashMap<>();
        params.put("to", to);
        params.put("nombre", nombre);
        params.put("partidos", partidos);
        params.put("motivo", motivo);
        enviarEmail(TipoEmail.SANCION_JUGADOR, params);
    }

    // En EmailService.java
    public void enviarComunicado(String to, String asunto, String mensaje) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(asunto);

        // Crear contenido HTML para el comunicado
        String contenido = String.format("""
        <h2>Comunicado Oficial - Federación Aragonesa de Baloncesto</h2>
        <div style="background-color: #f5f5f5; padding: 20px; border-radius: 5px;">
            <p>%s</p>
        </div>
        <br>
        <p style="color: #666; font-size: 12px;">Este es un mensaje automático, por favor no responder a este email.</p>
        <p>Federación Aragonesa de Baloncesto</p>
        """, mensaje);

        helper.setText(contenido, true);
        mailSender.send(message);

        log.info("Comunicado enviado a: {} - Asunto: {}", to, asunto);
    }

    public void enviarInscripcionEquipo(String to, String nombre,
                                        String equipoNombre, String liga)
            throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject("Inscripción en equipo - Federación Aragonesa de Baloncesto");

        String contenido = String.format(
                "<h2>¡Bienvenido a tu nuevo equipo, %s!</h2>" +
                        "<p>Has sido inscrito oficialmente en el equipo <strong>%s</strong>.</p>" +
                        "<p><strong>Liga:</strong> %s</p>" +
                        "<p>Ya puedes acceder a la aplicación para ver la información de tu equipo, calendario de partidos y estadísticas.</p>" +
                        "<p>Si tienes alguna duda, contacta con tu entrenador o con la Federación.</p>" +
                        "<br>" +
                        "<p>Federación Aragonesa de Baloncesto</p>",
                nombre, equipoNombre, liga
        );

        helper.setText(contenido, true);
        mailSender.send(message);

        log.info("Email de inscripción enviado a: {} - Equipo: {}", to, equipoNombre);
    }

    public void enviarNotificacionSancionEntrenador(String to, String nombreEntrenador,
                                                    String nombreJugador, int partidos,
                                                    String motivo) throws MessagingException {
        Map<String, Object> params = new HashMap<>();
        params.put("to", to);
        params.put("nombreEntrenador", nombreEntrenador);
        params.put("nombreJugador", nombreJugador);
        params.put("partidos", partidos);
        params.put("motivo", motivo);
        enviarEmail(TipoEmail.NOTIFICACION_SANCION_ENTRENADOR, params);
    }

    public void enviarRecordatorioPartido(RecordatorioPartidoDTO dto) throws MessagingException {
        Map<String, Object> params = new HashMap<>();
        params.put("to", dto.getSendto());
        params.put("nombreUsuario", dto.getNombreUsuario());
        params.put("nombreRival", dto.getNombreRival());
        params.put("fecha", dto.getFecha());
        params.put("pabellon", dto.getPabellon());
        params.put("direccionPabellon", dto.getDireccionPabellon());
        enviarEmail(TipoEmail.RECORDATORIO_PARTIDO, params);
    }

    // Métodos privados para construir contenido
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
        };
    }

    private String construirContenido(TipoEmail tipo, Map<String, Object> params) {
        return switch (tipo) {
            case CODIGO_VERIFICACION -> String.format("""
                <h2>Bienvenido a la Federación Aragonesa de Baloncesto</h2>
                <p>Tu código de verificación es: <strong>%s</strong></p>
                <p>Este código expirará en 10 minutos.</p>
                <p>Si no has solicitado este registro, ignora este mensaje.</p>
                """, params.get("codigo"));

            case CUENTA_BLOQUEADA -> String.format("""
                <h2>Hola, %s</h2>
                <p>Tu cuenta ha sido <strong>suspendida</strong> temporalmente
                   por la Federación Aragonesa de Baloncesto.</p>
                <p>Si crees que es un error, responde a este email o
                   contacta con nosotros.</p>
                <br>
                <p>Federación Aragonesa de Baloncesto</p>
                """, params.get("nombre"));

            case CUENTA_DESBLOQUEADA -> String.format("""
                <h2>Hola, %s</h2>
                <p>Tu cuenta ha sido <strong>reactivada</strong>.</p>
                <p>Ya puedes volver a acceder a la app con normalidad.</p>
                <br>
                <p>Federación Aragonesa de Baloncesto</p>
                """, params.get("nombre"));

            case ASIGNACION_ENTRENADOR -> String.format("""
                <h2>Hola, %s</h2>
                <p>Has sido asignado/a como entrenador/a del equipo
                   <strong>%s</strong>.</p>
                <p>Ya puedes acceder a los datos del equipo, subir
                   alineaciones y ver el calendario desde la app.</p>
                <br>
                <p>Federación Aragonesa de Baloncesto</p>
                """, params.get("nombre"), params.get("equipoNombre"));

            case ASIGNACION_ARBITRO -> {
                java.time.LocalDateTime fecha = (java.time.LocalDateTime) params.get("fecha");
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                yield String.format("""
                    <h2>Hola, %s</h2>
                    <p>Se te ha asignado el siguiente partido:</p>
                    <table border="1" cellpadding="8">
                        <tr><th>Local</th><td>%s</td></tr>
                        <tr><th>Visitante</th><td>%s</td></tr>
                        <tr><th>Fecha</th><td>%s</td></tr>
                        <tr><th>Pabellón</th><td>%s</td></tr>
                    </table>
                    <p>Recuerda revisar los equipos antes del partido.</p>
                    <br>
                    <p>Federación Aragonesa de Baloncesto</p>
                    """, params.get("nombre"), params.get("equipoLocal"),
                        params.get("equipoVisitante"), fecha.format(formatter),
                        params.get("pabellon"));
            }

            case SANCION_JUGADOR -> String.format("""
                <h2>Hola, %s</h2>
                <p>La Federación Aragonesa de Baloncesto te comunica
                   que has recibido una <strong>sanción de %d partido(s)</strong>.</p>
                <p><strong>Motivo:</strong> %s</p>
                <p>Si deseas presentar alegaciones, responde a este email
                   en un plazo de 48 horas.</p>
                <br>
                <p>Federación Aragonesa de Baloncesto</p>
                """, params.get("nombre"), params.get("partidos"), params.get("motivo"));

            case NOTIFICACION_SANCION_ENTRENADOR -> String.format("""
                <h2>Hola, %s</h2>
                <p>Te informamos de que el jugador <strong>%s</strong>
                   de tu equipo ha recibido una sanción de
                   <strong>%d partido(s)</strong>.</p>
                <p><strong>Motivo:</strong> %s</p>
                <p>Tenlo en cuenta para la próxima convocatoria.</p>
                <br>
                <p>Federación Aragonesa de Baloncesto</p>
                """, params.get("nombreEntrenador"), params.get("nombreJugador"),
                    params.get("partidos"), params.get("motivo"));

            case RECORDATORIO_PARTIDO -> {
                java.time.LocalDateTime fecha = (java.time.LocalDateTime) params.get("fecha");
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                yield String.format("""
                    <h2>Hola, %s</h2>
                    <p>Te recordamos que tienes partido próximamente:</p>
                    <table border="1" cellpadding="8">
                        <tr><th>Rival</th><td>%s</td></tr>
                        <tr><th>Fecha y hora</th><td>%s</td></tr>
                        <tr><th>Pabellón</th><td>%s</td></tr>
                        <tr><th>Dirección</th><td>%s</td></tr>
                    </table>
                    <p>¡Mucha suerte!</p>
                    <br>
                    <p>Federación Aragonesa de Baloncesto</p>
                    """, params.get("nombreUsuario"), params.get("nombreRival"),
                        fecha.format(formatter), params.get("pabellon"),
                        params.get("direccionPabellon"));
            }
        };
    }

    // Método base para enviar emails
    private void enviar(String to, String subject, String contenido) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(contenido, true);

        mailSender.send(message);
        log.info("Email enviado a: {} - Asunto: {}", to, subject);
    }
}