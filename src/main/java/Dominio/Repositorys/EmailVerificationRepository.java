package Dominio.Repositorys;

import Dominio.Entity.EmailVerification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface EmailVerificationRepository extends JpaRepository<EmailVerification, Long> {



    Optional<EmailVerification> findByEmail(String email);


    Optional<EmailVerification> findByCodigo(String codigo);


    @Modifying
    @Query("DELETE FROM EmailVerification e WHERE e.expirationTime < :now")
    void deleteExpired(@Param("now") LocalDateTime now);
}