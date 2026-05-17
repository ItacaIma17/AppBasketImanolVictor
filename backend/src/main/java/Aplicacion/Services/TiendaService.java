package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Repositorys.*;
import Presentacion.DTOS.Tienda.CrearPedidoRequest;
import Presentacion.DTOS.Tienda.PedidoResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class TiendaService {

    private final PedidoRepository pedidoRepository;
    private final ProductoRepository productoRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;

    @Transactional
    public PedidoResponse crearPedido(CrearPedidoRequest request, String username) {
        Usuario usuario = userRepository.findByUsername(username);
        if (usuario == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }

        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El pedido no puede estar vacío");
        }

        Pedido pedido = new Pedido();
        pedido.setUsuario(usuario);
        pedido.setFechaPedido(LocalDateTime.now());
        pedido.setEstado("PENDIENTE");
        pedido.setTotal(0);

        double total = 0;

        for (CrearPedidoRequest.ItemPedidoDTO item : request.getItems()) {
            if (item.getCantidad() <= 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La cantidad debe ser mayor a 0");
            }

            Producto producto = productoRepository.findById(item.getProductoId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Producto no encontrado: " + item.getProductoId()));

            if (!producto.isActivo()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "El producto no está disponible: " + producto.getNombreProducto());
            }

            if (producto.getStock() < item.getCantidad()) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Stock insuficiente para: " + producto.getNombreProducto() +
                        ". Disponible: " + producto.getStock());
            }

            LineaPedido linea = new LineaPedido();
            linea.setPedido(pedido);
            linea.setProducto(producto);
            linea.setCantidad(item.getCantidad());
            linea.setPrecioUnitario(producto.getPrecio());
            linea.setNombreProducto(producto.getNombreProducto());

            pedido.getLineas().add(linea);
            total += producto.getPrecio() * item.getCantidad();
        }

        pedido.setTotal(Math.round(total * 100.0) / 100.0);
        Pedido saved = pedidoRepository.save(pedido);
        log.info("Pedido {} creado por usuario {} - Total: {}€", saved.getId(), username, saved.getTotal());
        return PedidoResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<PedidoResponse> misPedidos(String username) {
        Usuario usuario = userRepository.findByUsername(username);
        if (usuario == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }
        return pedidoRepository.findByUsuarioIdOrderByFechaPedidoDesc(usuario.getId())
                .stream()
                .map(PedidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public PedidoResponse obtenerPedido(Long pedidoId, String username) {
        Pedido pedido = pedidoRepository.findById(pedidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Pedido no encontrado"));

        if (!pedido.getUsuario().getUsername().equals(username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este pedido");
        }

        return PedidoResponse.fromEntity(pedido);
    }

    @Transactional
    public PedidoResponse cancelarPedido(Long pedidoId, String username) {
        Pedido pedido = pedidoRepository.findById(pedidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Pedido no encontrado"));

        if (!pedido.getUsuario().getUsername().equals(username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este pedido");
        }

        if ("PAGADO".equals(pedido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No se puede cancelar un pedido ya pagado");
        }

        if ("CANCELADO".equals(pedido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El pedido ya está cancelado");
        }

        pedido.setEstado("CANCELADO");
        return PedidoResponse.fromEntity(pedidoRepository.save(pedido));
    }

    @Transactional
    public PedidoResponse actualizarEstadoPedido(Long pedidoId, String nuevoEstado) {
        Pedido pedido = pedidoRepository.findById(pedidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Pedido no encontrado"));

        if (List.of("CANCELADO", "ENTREGADO").contains(pedido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "No se puede modificar un pedido en estado: " + pedido.getEstado());
        }
        if ("ENVIADO".equals(nuevoEstado) && !"PAGADO".equals(pedido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Solo se pueden enviar pedidos en estado PAGADO");
        }
        if ("ENTREGADO".equals(nuevoEstado) && !"ENVIADO".equals(pedido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Solo se pueden entregar pedidos en estado ENVIADO");
        }
        if (!List.of("ENVIADO", "ENTREGADO", "CANCELADO").contains(nuevoEstado)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Estado no válido: " + nuevoEstado);
        }

        pedido.setEstado(nuevoEstado);
        Pedido saved = pedidoRepository.save(pedido);
        log.info("Pedido {} actualizado a estado {}", pedidoId, nuevoEstado);

        try {
            String email = pedido.getUsuario().getEmail();
            String nombre = pedido.getUsuario().getNombre();
            if ("ENVIADO".equals(nuevoEstado)) {
                emailService.enviarPedidoEnviado(email, nombre, pedidoId);
            } else if ("ENTREGADO".equals(nuevoEstado)) {
                emailService.enviarPedidoEntregado(email, nombre, pedidoId);
            }
        } catch (Exception ex) {
            log.warn("No se pudo enviar email para pedido {} estado {}: {}", pedidoId, nuevoEstado, ex.getMessage());
        }

        return PedidoResponse.fromEntity(saved);
    }

    @Transactional
    public void marcarComoPagado(Pedido pedido) {
        pedido.setEstado("PAGADO");

        for (LineaPedido linea : pedido.getLineas()) {
            Producto producto = productoRepository.findByIdForUpdate(linea.getProducto().getIdProducto())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Producto no encontrado al confirmar pago"));

            if (producto.getStock() < linea.getCantidad()) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Stock insuficiente para: " + producto.getNombreProducto() +
                        ". Disponible: " + producto.getStock());
            }

            producto.setStock(producto.getStock() - linea.getCantidad());
            productoRepository.save(producto);
        }

        pedidoRepository.save(pedido);
        log.info("Pedido {} marcado como PAGADO. Stock actualizado.", pedido.getId());
    }
}
