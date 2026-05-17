package Aplicacion.Services;

import Dominio.Entity.Producto;
import Dominio.Repositorys.ProductoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class ProductoDataInitializer implements CommandLineRunner {

    private final ProductoRepository productoRepository;

    @Override
    public void run(String... args) {
        if (productoRepository.count() > 0) return;

        List<Producto> productos = List.of(
            producto("Camiseta FAB Aragón 2024 Local", "Camiseta oficial local temporada 2024. Tejido transpirable.", 50, 59.99, "Camisetas", null),
            producto("Camiseta FAB Aragón 2024 Visitante", "Camiseta oficial visitante temporada 2024. Tejido transpirable.", 40, 59.99, "Camisetas", null),
            producto("Camiseta Entreno FAB", "Camiseta de entrenamiento oficial del club. Secado rápido.", 80, 29.99, "Camisetas", null),
            producto("Camiseta Retro FAB 2010", "Edición limitada retro. Coleccionistas.", 15, 44.99, "Camisetas", null),
            producto("Balón Oficial FAB Match", "Balón de partido oficial categoría 7. Talla 7.", 30, 89.99, "Balones", null),
            producto("Balón Entrenamiento Pro", "Balón de entrenamiento resistente. Talla 7.", 60, 49.99, "Balones", null),
            producto("Balón Mini FAB", "Mini balón decorativo con escudo FAB. Talla 3.", 100, 19.99, "Balones", null),
            producto("Bufanda FAB Aragón", "Bufanda oficial del club. Acrílico de alta calidad.", 200, 14.99, "Accesorios", null),
            producto("Gorra FAB Aragón", "Gorra con escudo bordado. Talla única regulable.", 150, 19.99, "Accesorios", null),
            producto("Bolsa Deporte FAB", "Bolsa oficial para equipamiento. 40L.", 70, 34.99, "Accesorios", null),
            producto("Botella Acero FAB", "Botella de acero inoxidable 750ml con logo FAB.", 120, 24.99, "Accesorios", null),
            producto("Zapatillas Basket FAB Edition", "Zapatillas edición especial FAB. Suela antideslizante.", 25, 129.99, "Equipamiento", null),
            producto("Rodilleras Pro Basketball", "Rodilleras de protección nivel profesional. Par.", 90, 22.99, "Equipamiento", null),
            producto("Tobilleras Compresión FAB", "Tobilleras de compresión para máximo rendimiento. Par.", 85, 18.99, "Equipamiento", null),
            producto("Pantalón Oficial FAB", "Pantalón corto oficial de partido. Tejido ligero.", 45, 39.99, "Equipamiento", null)
        );

        productoRepository.saveAll(productos);
        log.info("Productos iniciales cargados: {} productos", productos.size());
    }

    private Producto producto(String nombre, String desc, int stock, double precio, String cat, String img) {
        Producto p = new Producto();
        p.setNombreProducto(nombre);
        p.setDescripcion(desc);
        p.setStock(stock);
        p.setPrecio(precio);
        p.setCategoria(cat);
        p.setImagenUrl(img);
        p.setActivo(true);
        return p;
    }
}
