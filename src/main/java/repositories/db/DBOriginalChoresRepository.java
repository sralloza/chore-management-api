package repositories.db;

import models.db.DBOriginalChore;

import java.util.List;

public interface DBOriginalChoresRepository {
    List<DBOriginalChore> getAll();
}
