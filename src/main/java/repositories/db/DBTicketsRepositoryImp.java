package repositories.db;

import models.db.DBTicket;

import java.util.List;

public class DBTicketsRepositoryImp implements DBTicketsRepository{
    @Override
    public List<DBTicket> getAll() {
        return List.of(
                new DBTicket(1L, "type1", "user1", 0)
        );
    }
}
