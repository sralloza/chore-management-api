package es.sralloza.choremanagementapi.repositories.db;

import es.sralloza.choremanagementapi.models.db.DBUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DBUsersRepository extends JpaRepository<DBUser, Long> {
}
