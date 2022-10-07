package es.sralloza.choremanagementapi.repositories.db;

import es.sralloza.choremanagementapi.models.db.DBFlat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DBFlatsRepository extends JpaRepository<DBFlat, String> {
}
