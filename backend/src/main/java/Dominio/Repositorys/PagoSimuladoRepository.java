package Dominio.Repositorys;

import Dominio.Entity.PagoSimulado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PagoSimuladoRepository extends JpaRepository<PagoSimulado, Long> {
    Optional<PagoSimulado> findByTransaccionId(String transaccionId);
    Optional<PagoSimulado> findByPedidoId(Long pedidoId);
}
