package es.sralloza.choremanagementbot.repositories.db;

import es.sralloza.choremanagementbot.models.db.DBSkippedWeek;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DBSkippedWeekRepository extends JpaRepository<DBSkippedWeek, Long> {
    Optional<DBSkippedWeek> findByWeekIdAndTenantId(String weekId, Long tenantId);
}
