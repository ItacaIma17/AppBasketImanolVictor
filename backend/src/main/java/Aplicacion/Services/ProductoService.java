package Aplicacion.Services;

import Dominio.Entity.Producto;
import Dominio.Repositorys.ProductoRepository;
import Presentacion.DTOS.Producto.ProductoRequest;
import Presentacion.DTOS.Producto.ProductoResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductoService {

    private final ProductoRepository productoRepository;

    public ProductoResponse crearProducto(ProductoRequest dto) {
        Producto producto = new Producto();
        producto.setNombreProducto(dto.getNombreProducto());
        producto.setDescripcion(dto.getDescripcion());
        producto.setPrecio(dto.getPrecio());
        producto.setStock(dto.getStock());
        producto.setCategoria(dto.getCategoria());
        producto.setImagenUrl(dto.getImagenUrl());
        producto.setActivo(true);
        return ProductoResponse.fromEntity(productoRepository.save(producto));
    }

    public List<ProductoResponse> listarProductos() {
        return productoRepository.findAll()
                .stream()
                .filter(Producto::isActivo)
                .map(ProductoResponse::fromEntity)
                .toList();
    }

    public ProductoResponse obtenerProducto(Long id) {
        return ProductoResponse.fromEntity(productoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Producto no encontrado")));
    }

    public ProductoResponse actualizarProducto(Long id, ProductoRequest dto) {
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Producto no encontrado"));
        producto.setNombreProducto(dto.getNombreProducto());
        producto.setDescripcion(dto.getDescripcion());
        producto.setPrecio(dto.getPrecio());
        producto.setStock(dto.getStock());
        producto.setCategoria(dto.getCategoria());
        producto.setImagenUrl(dto.getImagenUrl());
        return ProductoResponse.fromEntity(productoRepository.save(producto));
    }

    public void eliminarProducto(Long id) {
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Producto no encontrado"));
        producto.setActivo(false);
        productoRepository.save(producto);
    }
}
