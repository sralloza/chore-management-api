package es.sralloza.choremanagementbot.repositories.db;

import es.sralloza.choremanagementbot.models.db.DBTenant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DBTenantsRepository extends JpaRepository<DBTenant, Integer> {
}
