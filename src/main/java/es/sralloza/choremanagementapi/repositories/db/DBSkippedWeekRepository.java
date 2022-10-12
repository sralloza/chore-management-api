package es.sralloza.choremanagementapi.repositories.db;

import es.sralloza.choremanagementapi.models.db.DBSkippedWeek;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DBSkippedWeekRepository extends JpaRepository<DBSkippedWeek, Long> {
    Optional<DBSkippedWeek> findByWeekIdAndUserId(String weekId, Long userId);
}
