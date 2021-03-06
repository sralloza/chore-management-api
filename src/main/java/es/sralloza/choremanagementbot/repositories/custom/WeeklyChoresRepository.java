package es.sralloza.choremanagementbot.repositories.custom;

import es.sralloza.choremanagementbot.builders.ChoreMapper;
import es.sralloza.choremanagementbot.builders.WeeklyChoresMapper;
import es.sralloza.choremanagementbot.exceptions.NotFoundException;
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
    @Autowired
    private ChoresRepository choresRepository;
    @Autowired
    private DBChoresRepository dbChoresRepository;
    @Autowired
    private DBRotationRepository dbRotationRepository;
    @Autowired
    private ChoreMapper choreMapper;
    @Autowired
    private WeeklyChoresMapper weeklyChoresMapper;

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

    public void save(WeeklyChores weeklyChores, String tenantsHash) {
        List<Chore> chores = weeklyChores.getChores();
        List<DBChore> result = chores.stream()
                .map(choreMapper::splitChore)
                .flatMap(Collection::stream)
                .collect(Collectors.toList());

        var rotation = new DBRotation()
                .setWeekId(weeklyChores.getWeekId())
                .setRotation(weeklyChores.getRotation())
                .setTenantIdsHash(tenantsHash);
        dbRotationRepository.save(rotation);
        dbChoresRepository.saveAll(result);
    }

    public void deleteByWeekId(String weekId) {
        var dbChoreList = dbChoresRepository.findAll().stream()
                .filter(chore -> chore.getWeekId().equals(weekId))
                .collect(Collectors.toList());
        if (dbChoreList.isEmpty()) {
            throw new NotFoundException("No chores found for week " + weekId);
        }
        dbChoresRepository.deleteAll(dbChoreList);

        var dbRotation = dbRotationRepository.findAll().stream()
                .filter(rotation -> rotation.getWeekId().equals(weekId))
                .collect(Collectors.toList());
        if (dbRotation.isEmpty()) {
            throw new NotFoundException("No rotation found for week " + weekId);
        }
        dbRotationRepository.deleteAll(dbRotation);
    }
}
