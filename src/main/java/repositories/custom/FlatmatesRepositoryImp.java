package repositories.custom;

import builders.FlatmateMapper;
import models.custom.Chore;
import models.custom.Flatmate;
import repositories.db.DBFlatmatesRepository;

import javax.inject.Inject;
import java.util.List;
import java.util.stream.Collectors;

public class FlatmatesRepositoryImp implements FlatmatesRepository {
    private final ChoresRepository choresRepository;
    private final DBFlatmatesRepository dbFlatmatesRepository;
    private final FlatmateMapper mapper;

    @Inject
    public FlatmatesRepositoryImp(ChoresRepository choresRepository,
                                  DBFlatmatesRepository dbFlatmatesRepository,
                                  FlatmateMapper mapper) {
        this.choresRepository = choresRepository;
        this.dbFlatmatesRepository = dbFlatmatesRepository;
        this.mapper = mapper;
    }

    @Override
    public List<Flatmate> getAll() {
        List<Chore> chores = choresRepository.getAll();
        return dbFlatmatesRepository.getAll().stream()
                .map(dbFlatmate -> mapper.build(dbFlatmate, chores))
                .collect(Collectors.toList());
    }
}
