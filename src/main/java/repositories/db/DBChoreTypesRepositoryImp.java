package repositories.db;

import models.db.DBChoreType;

import java.util.List;

public class DBChoreTypesRepositoryImp implements DBChoreTypesRepository {
    @Override
    public List<DBChoreType> getAll() {
        return List.of(
                new DBChoreType("type1", "Type1 description"),
                new DBChoreType("type2", "Type2 description"),
                new DBChoreType("type3", "Type3 description")
        );
    }
}
