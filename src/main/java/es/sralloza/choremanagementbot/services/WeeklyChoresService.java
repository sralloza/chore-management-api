package es.sralloza.choremanagementbot.services;

import es.sralloza.choremanagementbot.exceptions.BadRequestException;
import es.sralloza.choremanagementbot.exceptions.ConflictException;
import es.sralloza.choremanagementbot.exceptions.NotFoundException;
import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.models.db.DBChoreType;
import es.sralloza.choremanagementbot.models.db.DBRotation;
import es.sralloza.choremanagementbot.repositories.custom.TenantsRepository;
import es.sralloza.choremanagementbot.repositories.custom.WeeklyChoresRepository;
import es.sralloza.choremanagementbot.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementbot.repositories.db.DBRotationRepository;
import es.sralloza.choremanagementbot.utils.ChoreUtils;
import es.sralloza.choremanagementbot.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
public class WeeklyChoresService {
    @Autowired
    private WeeklyChoresRepository weeklyChoresRepository;

    @Autowired
    private DBChoreTypesRepository choreTypesRepository;

    @Autowired
    private TenantsRepository tenantsRepository;

    @Autowired
    private DBRotationRepository dbRotationRepository;

    @Autowired
    private DateUtils dateUtils;

    @Autowired
    private ChoreUtils choreUtils;

    public WeeklyChores createNextWeekChores() {
        String weekId = dateUtils.getWeekIdByDeltaDays(7);
        return createWeeklyChores(weekId);
    }

    public WeeklyChores createWeeklyChores(String weekId) {
        boolean alreadyExists = weeklyChoresRepository.findAll().stream()
                .anyMatch(weeklyChores -> weeklyChores.getWeekId().equals(weekId));
        if (alreadyExists) {
            throw new ConflictException("Weekly chores for week " + weekId + " already exist");
        }

        List<WeeklyChores> weeklyChoresList = weeklyChoresRepository.findAll();

        if (weeklyChoresList.isEmpty()) {
            WeeklyChores weeklyChores = createWeeklyChores(weekId, 0);
            weeklyChoresRepository.save(weeklyChores);
            return weeklyChores;
        }

        int lastRotation = dbRotationRepository.findAll().stream()
                .max(Comparator.comparing(DBRotation::getWeekId))
                .map(DBRotation::getRotation)
                .orElse(0);

        WeeklyChores weeklyChores = createWeeklyChores(weekId, lastRotation + 1);
        weeklyChoresRepository.save(weeklyChores);
        return weeklyChores;
    }

    private WeeklyChores createWeeklyChores(String weekId, int rotation) {
        List<String> choreTypes = choreTypesRepository.findAll().stream()
                .map(DBChoreType::getId)
                .collect(Collectors.toList());
        List<Tenant> tenants = tenantsRepository.getAll();

        List<Chore> chores = distributeChores(choreTypes, tenants, weekId, rotation);
        return new WeeklyChores()
                .setWeekId(weekId)
                .setChores(chores)
                .setRotation(rotation);
    }

    private List<Chore> distributeChores(List<String> choreTypes, List<Tenant> tenants,
                                         String weekId, int rotation) {

        if (tenants.isEmpty()) {
            throw new BadRequestException("Can't create weekly chores, no tenants registered");
        }

        if (choreTypes.isEmpty()) {
            throw new BadRequestException("Can't create weekly chores, no chore types registered");
        }

        int arraySize = Integer.max(choreTypes.size(), tenants.size()) * 2;
        rotation = rotation % tenants.size();

        List<Tenant> repeatedTenants = choreUtils.repeatArray(tenants, arraySize);
        Collections.rotate(repeatedTenants, -rotation);
        return IntStream.range(0, choreTypes.size())
                .mapToObj(n -> createChore(weekId, choreTypes.get(n), repeatedTenants.get(n)))
                .collect(Collectors.toList());
    }

    private Chore createChore(String weekId, String type, Tenant assignee) {
        Integer id = assignee.getTelegramId();
        return new Chore(weekId, type, List.of(id), false);
    }

    public List<WeeklyChores> findAll() {
        return weeklyChoresRepository.findAll();
    }

    public Optional<WeeklyChores> getByWeekId(String weekId) {
        return weeklyChoresRepository.findByWeekId(weekId);
    }

    public void deleteWeeklyChores(String weekId) {
        boolean exists = weeklyChoresRepository.findAll().stream()
                .anyMatch(weeklyChores -> weeklyChores.getWeekId().equals(weekId));
        if (!exists) {
            throw new NotFoundException("No weekly chores found for week " + weekId);
        }
        weeklyChoresRepository.deleteByWeekId(weekId);
    }
}
