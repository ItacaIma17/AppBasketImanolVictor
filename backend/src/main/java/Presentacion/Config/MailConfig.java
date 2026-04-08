package Presentacion.Config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import java.util.Properties;

@Configuration
public class MailConfig {

    @Bean
    public JavaMailSender javaMailSender() {
        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();

        // Configuración básica
        mailSender.setHost("smtp.gmail.com");
        mailSender.setPort(587);
        mailSender.setUsername("imanollapizondocarreras@gmail.com");
        mailSender.setPassword("oxrscakwredlmuxn");

        // Propiedades JavaMail
        Properties props = mailSender.getJavaMailProperties();

        // Protocolo SMTP
        props.put("mail.transport.protocol", "smtp");
        props.put("mail.smtp.auth", "true");

        // STARTTLS
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");

        // Timeouts
        props.put("mail.smtp.connectiontimeout", "50000");
        props.put("mail.smtp.timeout", "50000");
        props.put("mail.smtp.writetimeout", "50000");

        // Debug
        props.put("mail.debug", "true");

        return mailSender;
    }
}
