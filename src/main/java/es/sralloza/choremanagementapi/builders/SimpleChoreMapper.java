package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.SimpleChore;
import es.sralloza.choremanagementapi.models.db.DBChore;
import org.springframework.stereotype.Service;

@Service
public class SimpleChoreMapper {
    public SimpleChore build(DBChore dbChore) {
        return new SimpleChore()
            .setChoreType(dbChore.getChoreType())
            .setUserId(dbChore.getUserId())
            .setWeekId(dbChore.getWeekId())
            .setDone(dbChore.getDone());
    }
}
