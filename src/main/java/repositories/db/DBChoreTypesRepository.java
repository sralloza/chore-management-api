package repositories.db;

import models.db.DBChoreType;

import java.util.List;

public interface DBChoreTypesRepository {
    List<DBChoreType> getAll();
}
