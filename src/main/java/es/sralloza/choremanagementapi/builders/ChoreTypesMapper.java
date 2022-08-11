package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.custom.ChoreType;
import es.sralloza.choremanagementapi.models.db.DBChoreType;
import org.springframework.stereotype.Service;

@Service
public class ChoreTypesMapper {
    public ChoreType build(DBChoreType choreType) {
        return new ChoreType()
                .setId(choreType.getId())
                .setDescription(choreType.getDescription());
    }

    public DBChoreType build(ChoreType choreType) {
        return new DBChoreType()
                .setId(choreType.getId())
                .setDescription(choreType.getDescription());
    }
}
