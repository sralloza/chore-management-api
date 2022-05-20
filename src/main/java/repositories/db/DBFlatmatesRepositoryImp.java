package repositories.db;

import models.db.DBFlatmate;

import java.util.List;
import java.util.UUID;

public class DBFlatmatesRepositoryImp implements DBFlatmatesRepository {
    @Override
    public List<DBFlatmate> getAll() {
        return List.of(
                new DBFlatmate(1, "user1", UUID.randomUUID()),
                new DBFlatmate(2, "user2", UUID.randomUUID()),
                new DBFlatmate(3, "user3", UUID.randomUUID())
        );
    }
}
