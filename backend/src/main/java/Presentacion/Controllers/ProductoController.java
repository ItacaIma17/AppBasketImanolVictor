package Presentacion.Controllers;



import Aplicacion.Services.ProductoService;
import Presentacion.DTOS.Producto.ProductoRequest;
import Presentacion.DTOS.Producto.ProductoResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/productos")
@RequiredArgsConstructor
public class ProductoController {

    private final ProductoService productoService;

    @PostMapping("/crear")
    public ResponseEntity<ProductoResponse> crearProducto(@RequestBody ProductoRequest dto){
        return ResponseEntity.ok(productoService.crearProducto(dto));
    }

    @GetMapping("/listar")
    public ResponseEntity<List<ProductoResponse>> listarProductos(){
        return ResponseEntity.ok(productoService.listarProductos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductoResponse> obtenerProducto(@PathVariable Long id){
        return ResponseEntity.ok(productoService.obtenerProducto(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductoResponse> actualizarProducto(@PathVariable Long id, @RequestBody ProductoRequest dto){
        return ResponseEntity.ok(productoService.actualizarProducto(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarProducto(@PathVariable Long id){
        productoService.eliminarProducto(id);
        return ResponseEntity.noContent().build();
    }
}
