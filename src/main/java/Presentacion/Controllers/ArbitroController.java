package Presentacion.Controllers;

import Aplicacion.Services.ArbitroService;
import Dominio.Entity.Arbitro;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/arbitros")
@RequiredArgsConstructor
public class ArbitroController {

    private final ArbitroService arbitroService;

    @GetMapping("/{codigo}")
    public ResponseEntity<Arbitro> obtenerPorCodigo(@PathVariable String codigo) {
        return ResponseEntity.ok(arbitroService.obtenerPorCodigo(codigo));
    }
}