package es.sralloza.choremanagementbot.repositories.custom;

import es.sralloza.choremanagementbot.builders.ChoreMapper;
import es.sralloza.choremanagementbot.builders.WeeklyChoresMapper;
import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.models.db.DBChore;
import es.sralloza.choremanagementbot.models.db.DBRotation;
import es.sralloza.choremanagementbot.repositories.db.DBChoresRepository;
import es.sralloza.choremanagementbot.repositories.db.DBRotationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
public class WeeklyChoresRepository {
    private final ChoresRepository choresRepository;
    private final DBChoresRepository dbChoresRepository;
    private final DBRotationRepository dbRotationRepository;
    private final ChoreMapper choreMapper;
    private final WeeklyChoresMapper weeklyChoresMapper;

    @Autowired
    public WeeklyChoresRepository(ChoresRepository choresRepository,
                                  DBChoresRepository dbChoresRepository,
                                  DBRotationRepository dbRotationRepository,
                                  ChoreMapper choreMapper,
                                  WeeklyChoresMapper weeklyChoresMapper) {
        this.choresRepository = choresRepository;
        this.dbChoresRepository = dbChoresRepository;
        this.dbRotationRepository = dbRotationRepository;
        this.choreMapper = choreMapper;
        this.weeklyChoresMapper = weeklyChoresMapper;
    }

    public Optional<WeeklyChores> findByWeekId(String weekId) {
        return findAll().stream()
                .filter(weeklyChores -> weekId.equals(weeklyChores.getWeekId()))
                .findAny();
    }

    public List<WeeklyChores> findAll() {
        List<Chore> chores = choresRepository.getAll();
        List<DBRotation> rotations = dbRotationRepository.findAll();
        Map<String, Integer> rotationsMap = rotations.stream()
                .collect(Collectors.toMap(DBRotation::getWeekId, DBRotation::getRotation));

        return chores.stream()
                .collect(Collectors.groupingBy(Chore::getWeekId))
                .entrySet().stream()
                .map(entry -> weeklyChoresMapper.build(
                        entry.getKey(), entry.getValue(), rotationsMap.getOrDefault(entry.getKey(), null)))
                .sorted(Comparator.comparing(WeeklyChores::getWeekId))
                .collect(Collectors.toList());
    }

    public void save(WeeklyChores weeklyChores) {
        List<Chore> chores = weeklyChores.getChores();
        List<DBChore> result = chores.stream()
                .map(choreMapper::splitChore)
                .flatMap(Collection::stream)
                .collect(Collectors.toList());

        var rotation = new DBRotation(null, weeklyChores.getWeekId(), weeklyChores.getRotation());
        dbRotationRepository.save(rotation);
        dbChoresRepository.saveAll(result);
    }
}
