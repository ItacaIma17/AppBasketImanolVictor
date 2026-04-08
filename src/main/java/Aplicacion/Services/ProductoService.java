package Aplicacion.Services;


import Dominio.Entity.Producto;
import Dominio.Repositorys.ProductoRepository;
import Presentacion.DTOS.Producto.ProductoRequest;
import Presentacion.DTOS.Producto.ProductoResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductoService {

    private final ProductoRepository productoRepository;

    public ProductoResponse crearProducto(ProductoRequest dto){

        Producto producto = new Producto();
        producto.setNombreProducto(dto.getNombreProducto());
        producto.setPrecio(dto.getPrecio());
        producto.setStock(dto.getStock());

        productoRepository.save(producto);

        return mapToDTO(producto);
    }

    public List<ProductoResponse> listarProductos(){
        return productoRepository.findAll()
                .stream()
                .map(this::mapToDTO)
                .toList();
    }

    public ProductoResponse obtenerProducto(Long id){
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));

        return mapToDTO(producto);
    }

    public ProductoResponse actualizarProducto(Long id, ProductoRequest dto){

        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));

        producto.setNombreProducto(dto.getNombreProducto());
        producto.setPrecio(dto.getPrecio());
        producto.setStock(dto.getStock());

        productoRepository.save(producto);

        return mapToDTO(producto);
    }

    public void eliminarProducto(Long id){
        productoRepository.deleteById(id);
    }

    private ProductoResponse mapToDTO(Producto producto){

        ProductoResponse dto = new ProductoResponse();
        dto.setIdProducto(producto.getIdProducto());
        dto.setNombreProducto(producto.getNombreProducto());
        dto.setPrecio(producto.getPrecio());
        dto.setStock(producto.getStock());

        return dto;
    }
}
