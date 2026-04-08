package Dominio.Repositorys;

import Dominio.Entity.Liga;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LigaRepository extends JpaRepository<Liga, Long> {
    boolean existsByNombreLiga(String nombreLiga);
    Liga findByNombreLiga(String nombreLiga);
}