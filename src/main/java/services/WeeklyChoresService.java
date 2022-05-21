package services;

import exceptions.NotImplementedException;
import models.custom.Chore;
import models.custom.Flatmate;
import models.custom.WeeklyChores;
import models.db.DBChoreType;
import repositories.custom.FlatmatesRepository;
import repositories.custom.WeeklyChoresRepository;
import repositories.db.DBChoreTypesRepository;
import utils.ChoreUtils;
import utils.DateUtils;

import javax.inject.Inject;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class WeeklyChoresService {
    private final WeeklyChoresRepository weeklyChoresRepository;
    private final DBChoreTypesRepository choreTypesRepository;
    private final FlatmatesRepository flatmatesRepository;
    private final DateUtils dateUtils;
    private final ChoreUtils choreUtils;

    @Inject
    public WeeklyChoresService(WeeklyChoresRepository weeklyChoresRepository,
                               DBChoreTypesRepository choreTypesRepository,
                               FlatmatesRepository flatmatesRepository, DateUtils dateUtils,
                               ChoreUtils choreUtils) {
        this.weeklyChoresRepository = weeklyChoresRepository;
        this.choreTypesRepository = choreTypesRepository;
        this.flatmatesRepository = flatmatesRepository;
        this.dateUtils = dateUtils;
        this.choreUtils = choreUtils;
    }

    public WeeklyChores createWeeklyChores() {
        List<WeeklyChores> weeklyChoresList = weeklyChoresRepository.getAll();
        String weekId = dateUtils.getCurentWeekId();

        if (weeklyChoresList.isEmpty()) {
            return createFirstWeeklyChores(weekId);
        }

        WeeklyChores lastWeekChore = weeklyChoresList.stream()
                .max(Comparator.comparing(WeeklyChores::getWeekId))
                .orElseThrow(() -> new RuntimeException("Can't find weekly chore"));

        return new WeeklyChores()
                .setWeekId(weekId)
                .setChores(choreUtils.rotate(lastWeekChore.getChores(), weekId));
    }

    private WeeklyChores createFirstWeeklyChores(String weekId) {
        List<String> choreTypes = choreTypesRepository.getAll().stream()
                .map(DBChoreType::getId)
                .collect(Collectors.toList());
        List<Flatmate> flatmates = flatmatesRepository.getAll();

        List<Chore> chores = distributeChores(choreTypes, flatmates, weekId);
        return new WeeklyChores()
                .setWeekId(weekId)
                .setChores(chores);
    }

    private List<Chore> distributeChores(List<String> choreTypes, List<Flatmate> flatmates, String weekId) {
        // Same number of flatmates as tasks
        if (choreTypes.size() == flatmates.size()) {
            return IntStream.range(0, choreTypes.size())
                    .mapToObj(n -> createChore(weekId, choreTypes.get(n), flatmates.get(n)))
                    .collect(Collectors.toList());
        }

        throw new NotImplementedException("Can't create tasks: different number of Flatmates and Tasks defined");
    }

    private Chore createChore(String weekId, String type, Flatmate assignee) {
        Integer id = assignee.getTelegramId();
        return new Chore(weekId, type, List.of(id), List.of(id), false);
    }
}
