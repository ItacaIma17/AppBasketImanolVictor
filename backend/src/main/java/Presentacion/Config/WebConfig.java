package Presentacion.Config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins(
                        "http://localhost:3000",
                        "http://localhost:5000",
                        "http://127.0.0.1:3000",
                        "http://127.0.0.1:5000",
                        "http://192.168.1.145:3000",  // ← Tu IP con puerto 3000 (Flutter web)
                        "http://192.168.1.145:5000",  // ← Tu IP con puerto 5000 (Flutter web)
                        "http://192.168.1.145:8080",  // ← Tu IP con puerto 8080
                        "http://10.0.2.2:8080"        // ← Para emulador Android
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}