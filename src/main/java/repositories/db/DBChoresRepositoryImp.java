package repositories.db;

import models.db.DBChore;

import java.util.List;

public class DBChoresRepositoryImp implements DBChoresRepository {
    @Override
    public List<DBChore> getAll() {
        return List.of(
                new DBChore(1L, "chore1", 1, "2022.20", true),
                new DBChore(2L, "chore1", 2, "2022.20", true),
                new DBChore(2L, "chore2", 3, "2022.20", true),
                new DBChore(3L, "chore1", 3, "2022.21", false)
        );
    }
}
