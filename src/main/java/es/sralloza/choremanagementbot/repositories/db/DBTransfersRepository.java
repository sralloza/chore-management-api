package es.sralloza.choremanagementbot.repositories.db;

import es.sralloza.choremanagementbot.models.db.DBTransfer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DBTransfersRepository extends JpaRepository<DBTransfer, Long> {
}
