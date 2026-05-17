package Presentacion.DTOS.Producto;

import Dominio.Entity.Producto;
import lombok.Data;

@Data
public class ProductoResponse {
    private Long idProducto;
    private String nombreProducto;
    private String descripcion;
    private int stock;
    private double precio;
    private String categoria;
    private String imagenUrl;
    private boolean activo;

    public static ProductoResponse fromEntity(Producto p) {
        ProductoResponse dto = new ProductoResponse();
        dto.setIdProducto(p.getIdProducto());
        dto.setNombreProducto(p.getNombreProducto());
        dto.setDescripcion(p.getDescripcion());
        dto.setStock(p.getStock());
        dto.setPrecio(p.getPrecio());
        dto.setCategoria(p.getCategoria());
        dto.setImagenUrl(p.getImagenUrl());
        dto.setActivo(p.isActivo());
        return dto;
    }
}
