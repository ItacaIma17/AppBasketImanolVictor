package Presentacion.DTOS.Producto;

import lombok.Data;

@Data
public class ProductoResponse {
    private int idProducto;
    private String nombreProducto;
    private int stock;
    private double precio;

    public ProductoResponse(){}

    public ProductoResponse(String nombreProducto, int stock, double precio) {
        this.nombreProducto = nombreProducto;
        this.stock = stock;
        this.precio = precio;
    }
}

