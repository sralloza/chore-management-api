package es.sralloza.choremanagementbot.services;

import es.sralloza.choremanagementbot.exceptions.NotImplementedException;
import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.Flatmate;
import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.models.db.DBChoreType;
import es.sralloza.choremanagementbot.repositories.custom.FlatmatesRepository;
import es.sralloza.choremanagementbot.repositories.custom.WeeklyChoresRepository;
import es.sralloza.choremanagementbot.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementbot.utils.ChoreUtils;
import es.sralloza.choremanagementbot.utils.DateUtils;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;

import javax.inject.Inject;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
public class WeeklyChoresService {
    @Autowired
    private final WeeklyChoresRepository weeklyChoresRepository;

    @Autowired
    private final DBChoreTypesRepository choreTypesRepository;

    @Autowired
    private final FlatmatesRepository flatmatesRepository;

    @Autowired
    private final DateUtils dateUtils;

    @Autowired
    private final ChoreUtils choreUtils;

    @Inject
    public WeeklyChoresService(WeeklyChoresRepository weeklyChoresRepository,
                               DBChoreTypesRepository choreTypesRepository,
                               FlatmatesRepository flatmatesRepository,
                               DateUtils dateUtils,
                               ChoreUtils choreUtils) {
        this.weeklyChoresRepository = weeklyChoresRepository;
        this.choreTypesRepository = choreTypesRepository;
        this.flatmatesRepository = flatmatesRepository;
        this.dateUtils = dateUtils;
        this.choreUtils = choreUtils;
    }


    public WeeklyChores createWeeklyChores() {
        String weekId = dateUtils.getCurrentWeekId();
        return createWeeklyChores(weekId);
    }

    public WeeklyChores createWeeklyChores(String weekId) {
        List<WeeklyChores> weeklyChoresList = weeklyChoresRepository.findAll();

        if (weeklyChoresList.isEmpty()) {
            System.out.println("Creating weeklyChores");
            WeeklyChores weeklyChores = createFirstWeeklyChores(weekId);
            System.out.println("Done, saving it: " + weeklyChores);
            weeklyChoresRepository.save(weeklyChores);
            return weeklyChores;
        }

        WeeklyChores lastWeekChore = weeklyChoresList.stream()
                .max(Comparator.comparing(WeeklyChores::getWeekId))
                .orElseThrow(() -> new RuntimeException("Can't find weekly chore"));

        var weeklyChores = new WeeklyChores()
                .setWeekId(weekId)
                .setChores(lastWeekChore.getChores());
        weeklyChoresRepository.save(weeklyChores);
        return weeklyChores;
    }

    private WeeklyChores createFirstWeeklyChores(String weekId) {
        List<String> choreTypes = choreTypesRepository.findAll().stream()
                .map(DBChoreType::getId)
                .collect(Collectors.toList());
        List<Flatmate> flatmates = flatmatesRepository.getAll();

        List<Chore> chores = distributeChores(choreTypes, flatmates, weekId, 0);
        return new WeeklyChores()
                .setWeekId(weekId)
                .setChores(chores)
                .setRotation(0);
    }

    private List<Chore> distributeChores(List<String> choreTypes, List<Flatmate> flatmates,
                                         String weekId, Integer rotation) {
        // Same number of flatmates as tasks
        int arraySize = Integer.max(choreTypes.size(), flatmates.size());
        List<Flatmate> repeatedFlatmates = choreUtils.repeatArray(flatmates, arraySize);
        Collections.rotate(repeatedFlatmates, rotation);
        if (choreTypes.size() == flatmates.size()) {
            return IntStream.range(0, choreTypes.size())
                    .mapToObj(n -> createChore(weekId, choreTypes.get(n), flatmates.get(n)))
                    .collect(Collectors.toList());
        }

        throw new NotImplementedException("Can't create tasks: different number of Flatmates and Tasks defined");
    }

    private Chore createChore(String weekId, String type, Flatmate assignee) {
        Integer id = assignee.getTelegramId();
        return new Chore(weekId, type, List.of(id), false);
    }

    public List<WeeklyChores> findAll() {
        return weeklyChoresRepository.findAll();
    }

    public Optional<WeeklyChores> getByWeekId(String weekId) {
        return weeklyChoresRepository.findByWeekId(weekId);
    }
}
