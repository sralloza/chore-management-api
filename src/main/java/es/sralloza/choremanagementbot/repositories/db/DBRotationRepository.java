package es.sralloza.choremanagementbot.repositories.db;

import es.sralloza.choremanagementbot.models.db.DBRotation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DBRotationRepository extends JpaRepository<DBRotation, Long> {
}
