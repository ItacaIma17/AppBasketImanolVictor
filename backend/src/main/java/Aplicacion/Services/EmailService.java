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
        COMUNICADO_GENERAL,
        PEDIDO_CONFIRMADO,
        PEDIDO_ENVIADO,
        PEDIDO_ENTREGADO
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

    public void sendHtmlMailWithAttachment(String to, String subject, String htmlContent,
                                            byte[] attachment, String attachmentFilename) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlContent, true);
        helper.addAttachment(attachmentFilename,
                new org.springframework.core.io.ByteArrayResource(attachment));
        mailSender.send(message);
        log.info(" Email con adjunto enviado a: {} - Asunto: {}", to, subject);
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

    public void enviarConfirmacionPedido(String to, String nombre, Long pedidoId,
                                          double total, java.util.List<String> lineasTexto) throws MessagingException {
        String subject = "Confirmación de pedido #" + pedidoId + " - FAB Tienda Oficial";
        StringBuilder itemsHtml = new StringBuilder();
        for (String linea : lineasTexto) {
            itemsHtml.append("<tr><td style='padding:8px 12px;border-bottom:1px solid #eee;color:#333;'>")
                     .append(linea).append("</td></tr>");
        }
        String content = String.format("""
            <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#f9f9f9;">
              <div style="background:linear-gradient(135deg,#CC0000 0%%,#FF6600 100%%);padding:32px;text-align:center;">
                <h1 style="color:white;margin:0;font-size:24px;">¡Gracias por tu compra, %s!</h1>
                <p style="color:rgba(255,255,255,0.9);margin:8px 0 0 0;">Federación Aragonesa de Baloncesto · Tienda Oficial</p>
              </div>
              <div style="background:white;padding:30px;">
                <div style="background:#f0fff4;border-left:4px solid #28a745;padding:14px 16px;border-radius:4px;margin-bottom:24px;">
                  <p style="margin:0;color:#28a745;font-weight:bold;font-size:15px;">✓ Pedido confirmado</p>
                  <p style="margin:4px 0 0 0;color:#555;">Número de pedido: <strong>#%d</strong></p>
                </div>
                <h3 style="color:#333;border-bottom:2px solid #FF6600;padding-bottom:8px;">Resumen del pedido</h3>
                <table style="width:100%%;border-collapse:collapse;background:#fafafa;border-radius:8px;overflow:hidden;">%s</table>
                <div style="margin-top:14px;text-align:right;background:#fff3e0;padding:12px 16px;border-radius:6px;">
                  <span style="font-size:20px;font-weight:bold;color:#FF6600;">Total: %.2f €</span>
                </div>
                <div style="margin-top:24px;background:#fff8e1;border-radius:8px;padding:18px;">
                  <h4 style="color:#FF6600;margin:0 0 10px 0;">¿Qué ocurre ahora?</h4>
                  <p style="color:#555;margin:0;line-height:1.7;">
                    Tu pedido está siendo preparado. Te enviaremos otro email cuando salga de nuestro almacén
                    y otro cuando llegue a tu dirección. Puedes seguir el estado en la app, en la sección <strong>Mis Pedidos</strong>.
                  </p>
                </div>
              </div>
              <div style="background:#2d2d2d;padding:16px;text-align:center;">
                <p style="color:#aaa;margin:0;font-size:12px;">Federación Aragonesa de Baloncesto · Mensaje automático, no respondas a este email.</p>
              </div>
            </div>
            """, nombre, pedidoId, itemsHtml.toString(), total);
        sendHtmlMail(to, subject, content);
    }

    public void enviarPedidoEnviado(String to, String nombre, Long pedidoId) throws MessagingException {
        String subject = "Tu pedido #" + pedidoId + " ha salido del almacén · FAB";
        String content = String.format("""
            <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#f9f9f9;">
              <div style="background:linear-gradient(135deg,#0055CC 0%%,#0099FF 100%%);padding:32px;text-align:center;">
                <div style="font-size:52px;">📦</div>
                <h1 style="color:white;margin:10px 0 0 0;font-size:22px;">¡Tu pedido está en camino!</h1>
              </div>
              <div style="background:white;padding:30px;">
                <p style="color:#333;font-size:15px;">Hola <strong>%s</strong>,</p>
                <div style="background:#e3f2fd;border-left:4px solid #0055CC;padding:14px 16px;border-radius:4px;margin:20px 0;">
                  <p style="margin:0;color:#0055CC;font-weight:bold;font-size:15px;">🚚 Pedido #%d enviado</p>
                  <p style="margin:8px 0 0 0;color:#555;">Tu paquete salió de nuestro almacén y está en camino hacia ti.</p>
                </div>
                <div style="margin:24px 0;">
                  <div style="display:flex;align-items:center;margin-bottom:14px;">
                    <div style="width:22px;height:22px;background:#28a745;border-radius:50%%;text-align:center;line-height:22px;color:white;font-size:12px;margin-right:12px;">✓</div>
                    <span style="color:#28a745;font-weight:bold;">Pedido confirmado y pagado</span>
                  </div>
                  <div style="display:flex;align-items:center;margin-bottom:14px;">
                    <div style="width:22px;height:22px;background:#0055CC;border-radius:50%%;text-align:center;line-height:22px;color:white;font-size:12px;margin-right:12px;">✓</div>
                    <span style="color:#0055CC;font-weight:bold;">En camino</span>
                  </div>
                  <div style="display:flex;align-items:center;">
                    <div style="width:22px;height:22px;background:#ddd;border-radius:50%%;margin-right:12px;"></div>
                    <span style="color:#aaa;">Entregado</span>
                  </div>
                </div>
                <p style="color:#666;">Recibirás otro email en cuanto tu paquete sea entregado.</p>
              </div>
              <div style="background:#2d2d2d;padding:16px;text-align:center;">
                <p style="color:#aaa;margin:0;font-size:12px;">Federación Aragonesa de Baloncesto · Mensaje automático, no respondas a este email.</p>
              </div>
            </div>
            """, nombre, pedidoId);
        sendHtmlMail(to, subject, content);
    }

    public void enviarPedidoEntregado(String to, String nombre, Long pedidoId) throws MessagingException {
        String subject = "¡Tu pedido #" + pedidoId + " ha llegado! · FAB";
        String content = String.format("""
            <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#f9f9f9;">
              <div style="background:linear-gradient(135deg,#00695c 0%%,#26a69a 100%%);padding:32px;text-align:center;">
                <div style="font-size:52px;">🏠</div>
                <h1 style="color:white;margin:10px 0 0 0;font-size:22px;">¡Tu pedido ha llegado!</h1>
              </div>
              <div style="background:white;padding:30px;">
                <p style="color:#333;font-size:15px;">Hola <strong>%s</strong>,</p>
                <div style="background:#e8f5e9;border-left:4px solid #28a745;padding:14px 16px;border-radius:4px;margin:20px 0;">
                  <p style="margin:0;color:#28a745;font-weight:bold;font-size:15px;">✓ Pedido #%d entregado</p>
                  <p style="margin:8px 0 0 0;color:#555;">Tu paquete ha sido entregado correctamente. ¡Esperamos que disfrutes tu compra!</p>
                </div>
                <div style="text-align:center;margin:28px 0;padding:24px;background:#f5f5f5;border-radius:12px;">
                  <div style="font-size:60px;">🏀</div>
                  <p style="color:#333;font-size:16px;margin:14px 0 0 0;font-weight:bold;">
                    ¡Gracias por comprar en la tienda oficial de la Federación Aragonesa de Baloncesto!
                  </p>
                </div>
              </div>
              <div style="background:#2d2d2d;padding:16px;text-align:center;">
                <p style="color:#aaa;margin:0;font-size:12px;">Federación Aragonesa de Baloncesto · Mensaje automático, no respondas a este email.</p>
              </div>
            </div>
            """, nombre, pedidoId);
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
            case PEDIDO_CONFIRMADO -> "Confirmación de pedido - FAB Shop";
            case PEDIDO_ENVIADO -> "Tu pedido está en camino - FAB Shop";
            case PEDIDO_ENTREGADO -> "¡Tu pedido ha llegado! - FAB Shop";
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

            case PEDIDO_CONFIRMADO -> String.format("""
                <h2>Pedido confirmado</h2>
                <p>Tu pedido #%s ha sido procesado correctamente.</p>
                """, params.get("pedidoId"));

            case PEDIDO_ENVIADO -> String.format("""
                <h2>Tu pedido está en camino</h2>
                <p>El pedido #%s ha sido enviado.</p>
                """, params.get("pedidoId"));

            case PEDIDO_ENTREGADO -> String.format("""
                <h2>¡Tu pedido ha llegado!</h2>
                <p>El pedido #%s ha sido entregado.</p>
                """, params.get("pedidoId"));
        };
    }
}
