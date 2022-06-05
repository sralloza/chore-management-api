package es.sralloza.choremanagementbot.repositories.db;

import es.sralloza.choremanagementbot.models.db.DBSkippedWeek;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DBSkippedWeekRepository extends JpaRepository<DBSkippedWeek, Long> {
}
