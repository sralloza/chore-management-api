package repositories.custom;

import builders.ChoreMapper;
import models.custom.Chore;
import repositories.db.DBChoresRepository;

import javax.inject.Inject;
import java.util.List;

public class ChoresRepositoryImp implements ChoresRepository {
    private final DBChoresRepository choreRepository;
    private final ChoreMapper choreMapper;

    @Inject
    public ChoresRepositoryImp(DBChoresRepository choreRepository, ChoreMapper choreMapper) {
        this.choreRepository = choreRepository;
        this.choreMapper = choreMapper;
    }

    @Override
    public List<Chore> getAll() {
        return choreMapper.build(choreRepository.getAll());
    }
}
