package es.sralloza.choremanagementbot.repositories.custom;

import es.sralloza.choremanagementbot.builders.FlatmateMapper;
import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.Flatmate;
import es.sralloza.choremanagementbot.repositories.db.DBFlatmatesRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import javax.inject.Inject;
import java.util.List;
import java.util.stream.Collectors;

@Repository
public class FlatmatesRepository {
    @Autowired
    private final ChoresRepository choresRepository;
    @Autowired
    private final DBFlatmatesRepository dbFlatmatesRepository;
    @Autowired
    private final FlatmateMapper mapper;

    public FlatmatesRepository(ChoresRepository choresRepository,
                               DBFlatmatesRepository dbFlatmatesRepository,
                               FlatmateMapper mapper) {
        this.choresRepository = choresRepository;
        this.dbFlatmatesRepository = dbFlatmatesRepository;
        this.mapper = mapper;
    }

    public List<Flatmate> getAll() {
        List<Chore> chores = choresRepository.getAll();
        return dbFlatmatesRepository.findAll().stream()
                .map(dbFlatmate -> mapper.build(dbFlatmate, chores))
                .collect(Collectors.toList());
    }
}
