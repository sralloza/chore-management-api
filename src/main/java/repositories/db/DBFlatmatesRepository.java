package repositories.db;

import models.db.DBFlatmate;

import java.util.List;

public interface DBFlatmatesRepository {
    List<DBFlatmate> getAll();
}
