package repositories.db;

import models.db.DBChore;

import java.util.List;

public interface DBChoresRepository {
    List<DBChore> getAll();
}
