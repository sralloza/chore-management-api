package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.exceptions.ConflictException;
import es.sralloza.choremanagementapi.exceptions.NotFoundException;
import es.sralloza.choremanagementapi.models.custom.Chore;
import es.sralloza.choremanagementapi.models.custom.User;
import es.sralloza.choremanagementapi.models.custom.WeeklyChores;
import es.sralloza.choremanagementapi.models.db.DBChoreType;
import es.sralloza.choremanagementapi.models.db.DBRotation;
import es.sralloza.choremanagementapi.models.db.DBSkippedWeek;
import es.sralloza.choremanagementapi.repositories.custom.WeeklyChoresRepository;
import es.sralloza.choremanagementapi.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementapi.repositories.db.DBRotationRepository;
import es.sralloza.choremanagementapi.repositories.db.DBSkippedWeekRepository;
import es.sralloza.choremanagementapi.utils.ChoreUtils;
import es.sralloza.choremanagementapi.utils.DateUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Nullable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
@Slf4j
public class WeeklyChoresService {
    @Autowired
    private WeeklyChoresRepository weeklyChoresRepository;
    @Autowired
    private DBChoreTypesRepository choreTypesRepository;
    @Autowired
    private UsersService usersService;
    @Autowired
    private DBRotationRepository dbRotationRepository;
    @Autowired
    private DBSkippedWeekRepository dbSkippedWeekRepository;
    @Autowired
    private DateUtils dateUtils;
    @Autowired
    private ChoreUtils choreUtils;

    public WeeklyChores createNextWeekChores(@Nullable Boolean force) {
        String weekId = dateUtils.getWeekIdByDeltaDays(7);
        return createWeeklyChores(weekId, force);
    }

    public WeeklyChores createWeeklyChores(String weekId, @Nullable Boolean force) {
        boolean alreadyExists = weeklyChoresRepository.findAll().stream()
            .anyMatch(weeklyChores -> weeklyChores.getWeekId().equals(weekId));
        if (alreadyExists) {
            throw new ConflictException("Weekly chores for week " + weekId + " already exist");
        }

        List<WeeklyChores> weeklyChoresList = weeklyChoresRepository.findAll();

        if (weeklyChoresList.isEmpty()) {
            WeeklyChores weeklyChores = createWeeklyChoresByRotation(weekId, 0);
            weeklyChoresRepository.save(weeklyChores, usersService.getUsersHash());
            return weeklyChores;
        }

        DBRotation lastRotation = dbRotationRepository.findAll().stream()
            .max(Comparator.comparing(DBRotation::getWeekId))
            .orElseThrow(() -> new RuntimeException("No rotations found creating weekly chores for week " + weekId));

        int newRotation = lastRotation.getRotation() + 1;
        if (!lastRotation.getUsersIdHash().equals(usersService.getUsersHash())) {
            if (!Boolean.TRUE.equals(force)) {
                throw new BadRequestException("Users have changed since weekly chore creation. Use force parameter " +
                    "to restart the weekly chores creation.");
            }
            log.info("Recreating weekly chores");
            newRotation = 0;
        }

        WeeklyChores weeklyChores = createWeeklyChoresByRotation(weekId, newRotation);
        weeklyChoresRepository.save(weeklyChores, usersService.getUsersHash());
        return weeklyChores;
    }

    private WeeklyChores createWeeklyChoresByRotation(String weekId, int rotation) {
        List<String> choreTypes = choreTypesRepository.findAll().stream()
            .map(DBChoreType::getId)
            .collect(Collectors.toList());
        List<User> users = usersService.listUsers();

        if (users.isEmpty()) {
            throw new BadRequestException("Can't create weekly chores, no users registered");
        }

        if (choreTypes.isEmpty()) {
            throw new BadRequestException("Can't create weekly chores, no chore types registered");
        }
        return createWeeklyChoresDistributingChores(choreTypes, users, weekId, rotation);
    }

    private WeeklyChores createWeeklyChoresDistributingChores(List<String> choreTypes, List<User> users,
                                                              String weekId, int rotation) {
        List<Long> userIdList = users.stream()
            .map(User::getUserId)
            .collect(Collectors.toList());

        Set<Long> usersSkippingWeek = dbSkippedWeekRepository.findAll().stream()
            .filter(dbSkippedWeek -> dbSkippedWeek.getWeekId().equals(weekId))
            .map(DBSkippedWeek::getUserId)
            .collect(Collectors.toSet());
        Set<Long> usersNotSkippingWeek = userIdList.stream()
            .filter(userId -> !usersSkippingWeek.contains(userId))
            .collect(Collectors.toSet());

        int arraySize = Integer.max(choreTypes.size(), users.size()) * 2;

        if (usersNotSkippingWeek.size() == 1) {
            var userAlone = usersNotSkippingWeek.iterator().next();
            rotation--;
            for (int i = 0; i < users.size(); i++) {
                userIdList.set(i, userAlone);
            }
        }
        rotation = rotation % users.size();

        List<Long> repeatedUsers = choreUtils.repeatArray(userIdList, arraySize);
        Collections.rotate(repeatedUsers, -rotation);

        var distributedChoreList = IntStream.range(0, choreTypes.size())
            .mapToObj(n -> {
                var userId = repeatedUsers.get(n);
                return createChore(weekId,
                    choreTypes.get(n),
                    userId,
                    usersSkippingWeek.contains(userId) ? usersNotSkippingWeek : null
                );
            })
            .collect(Collectors.toList());

        return new WeeklyChores()
            .setWeekId(weekId)
            .setChores(distributedChoreList)
            .setRotation(rotation);
    }

    private Chore createChore(String weekId, String type, Long userId, Set<Long> userIdListOverride) {
        List<Long> asigneeListIds = new ArrayList<>();

        if (userIdListOverride == null || userIdListOverride.isEmpty()) {
            asigneeListIds.add(userId);
        } else {
            asigneeListIds.addAll(userIdListOverride);
        }

        var asigneeListUsernames = asigneeListIds.stream()
            .map(usersService::getUserById)
            .map(User::getUsername)
            .collect(Collectors.toList());

        return new Chore(weekId, type, asigneeListIds, asigneeListUsernames, false);
    }

    public List<WeeklyChores> findAll(Boolean missingOnly) {
        return weeklyChoresRepository.findAll().stream()
            .filter(chore -> missingOnly == null || choreUtils.isMissing(chore).equals(missingOnly))
            .collect(Collectors.toList());
    }

    public Optional<WeeklyChores> getByWeekId(String weekId) {
        return weeklyChoresRepository.findByWeekId(weekId);
    }

    public WeeklyChores getByWeekIdOr404(String weekId) {
        return weeklyChoresRepository.findByWeekId(weekId)
            .orElseThrow(() -> getNotFoundException(weekId));
    }

    public void deleteWeeklyChores(String weekId) {
        boolean exists = weeklyChoresRepository.findAll().stream()
            .anyMatch(weeklyChores -> weeklyChores.getWeekId().equals(weekId));
        if (!exists) {
            throw getNotFoundException(weekId);
        }
        weeklyChoresRepository.deleteByWeekId(weekId);
    }

    private NotFoundException getNotFoundException(String weekId) {
        return new NotFoundException("No weekly chores found for week " + weekId);
    }

    public void completeWeeklyChores(String weekId, String choreType, Long userId) {
        weeklyChoresRepository.completeWeeklyChores(weekId, choreType, userId);
    }
}
