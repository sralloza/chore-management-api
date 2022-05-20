package repositories.db;

import models.db.DBTicket;

import java.util.List;

public interface DBTicketsRepository {
    List<DBTicket> getAll();
}
