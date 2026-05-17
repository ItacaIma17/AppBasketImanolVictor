package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "pagos_simulados")
@Data
public class PagoSimulado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pedido_id", nullable = false)
    private Pedido pedido;

    @Column(nullable = false, unique = true)
    private String transaccionId;

    private String ultimosCuatroDigitos;
    private String nombreTitular;
    private double importe;

    @Column(nullable = false)
    private String estado; // APROBADO, RECHAZADO

    private String mensaje;

    @Column(nullable = false)
    private LocalDateTime fechaPago;
}
