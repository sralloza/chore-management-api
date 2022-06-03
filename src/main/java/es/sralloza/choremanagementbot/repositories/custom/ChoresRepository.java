package es.sralloza.choremanagementbot.repositories.custom;

import es.sralloza.choremanagementbot.builders.ChoreMapper;
import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.repositories.db.DBChoresRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class ChoresRepository {
    @Autowired
    private final DBChoresRepository choreRepository;

    @Autowired
    private final ChoreMapper choreMapper;

    public ChoresRepository(DBChoresRepository choreRepository,
                            ChoreMapper choreMapper) {
        this.choreRepository = choreRepository;
        this.choreMapper = choreMapper;
    }

    public List<Chore> getAll() {
        return choreMapper.buildChore(choreRepository.findAll());
    }
}
