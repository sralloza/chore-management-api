package es.sralloza.choremanagementapi.repositories.db;

import es.sralloza.choremanagementapi.models.db.DBTicket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DBTicketsRepository extends JpaRepository<DBTicket, Long> {
}
