package repositories.custom;

import models.custom.Chore;
import models.custom.WeeklyChores;

import javax.inject.Inject;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class WeeklyChoresRepositoryImp implements WeeklyChoresRepository {
    private final ChoresRepository choresRepository;

    @Inject
    public WeeklyChoresRepositoryImp(ChoresRepository choresRepository) {
        this.choresRepository = choresRepository;
    }

    @Override
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
}
