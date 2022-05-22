package es.sralloza.choremanagementbot.repositories.custom;

import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.models.db.DBChore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Repository
public class WeeklyChoresRepository {
    @Autowired
    private final ChoresRepository choresRepository;

    public WeeklyChoresRepository(ChoresRepository choresRepository) {
        this.choresRepository = choresRepository;
    }

    public List<WeeklyChores> getAll() {
        List<Chore> chores = choresRepository.getAll();
        return chores.stream()
                .collect(Collectors.groupingBy(Chore::getWeekId))
                .entrySet().stream()
                .map(entry -> new WeeklyChores()
                        .setWeekId(entry.getKey())
                        .setChores(entry.getValue()))
                .sorted(Comparator.comparing(WeeklyChores::getWeekId))
                .collect(Collectors.toList());
    }

    public void save(WeeklyChores weeklyChores) {
        List<Chore> chores = weeklyChores.getChores();

    }
}
