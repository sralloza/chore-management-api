package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.exceptions.ConflictException;
import es.sralloza.choremanagementapi.exceptions.NotFoundException;
import es.sralloza.choremanagementapi.models.custom.Chore;
import es.sralloza.choremanagementapi.models.custom.Tenant;
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
    private TenantsService tenantsService;
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
            weeklyChoresRepository.save(weeklyChores, tenantsService.getTenantsHash());
            return weeklyChores;
        }

        DBRotation lastRotation = dbRotationRepository.findAll().stream()
            .max(Comparator.comparing(DBRotation::getWeekId))
            .orElseThrow(() -> new RuntimeException("No rotations found creating weekly chores for week " + weekId));

        int newRotation = lastRotation.getRotation() + 1;
        if (!lastRotation.getTenantIdsHash().equals(tenantsService.getTenantsHash())) {
            if (!Boolean.TRUE.equals(force)) {
                throw new BadRequestException("Tenants have changed since weekly chore creation. Use force parameter " +
                    "to restart the weekly chores creation.");
            }
            log.info("Recreating weekly chores");
            newRotation = 0;
        }

        WeeklyChores weeklyChores = createWeeklyChoresByRotation(weekId, newRotation);
        weeklyChoresRepository.save(weeklyChores, tenantsService.getTenantsHash());
        return weeklyChores;
    }

    private WeeklyChores createWeeklyChoresByRotation(String weekId, int rotation) {
        List<String> choreTypes = choreTypesRepository.findAll().stream()
            .map(DBChoreType::getId)
            .collect(Collectors.toList());
        List<Tenant> tenants = tenantsService.listTenants();

        if (tenants.isEmpty()) {
            throw new BadRequestException("Can't create weekly chores, no tenants registered");
        }

        if (choreTypes.isEmpty()) {
            throw new BadRequestException("Can't create weekly chores, no chore types registered");
        }
        return createWeeklyChoresDistributingChores(choreTypes, tenants, weekId, rotation);
    }

    private WeeklyChores createWeeklyChoresDistributingChores(List<String> choreTypes, List<Tenant> tenants,
                                                              String weekId, int rotation) {
        List<Long> tenantIdList = tenants.stream()
            .map(Tenant::getTenantId)
            .collect(Collectors.toList());

        Set<Long> tenantsSkippingWeek = dbSkippedWeekRepository.findAll().stream()
            .filter(dbSkippedWeek -> dbSkippedWeek.getWeekId().equals(weekId))
            .map(DBSkippedWeek::getTenantId)
            .collect(Collectors.toSet());
        Set<Long> tenantsNotSkippingWeek = tenantIdList.stream()
            .filter(tenantId -> !tenantsSkippingWeek.contains(tenantId))
            .collect(Collectors.toSet());

        int arraySize = Integer.max(choreTypes.size(), tenants.size()) * 2;

        if (tenantsNotSkippingWeek.size() == 1) {
            var tenantAlone = tenantsNotSkippingWeek.iterator().next();
            rotation--;
            for (int i = 0; i < tenants.size(); i++) {
                tenantIdList.set(i, tenantAlone);
            }
        }
        rotation = rotation % tenants.size();

        List<Long> repeatedTenants = choreUtils.repeatArray(tenantIdList, arraySize);
        Collections.rotate(repeatedTenants, -rotation);

        var distributedChoreList = IntStream.range(0, choreTypes.size())
            .mapToObj(n -> {
                var tenantId = repeatedTenants.get(n);
                return createChore(weekId,
                    choreTypes.get(n),
                    tenantId,
                    tenantsSkippingWeek.contains(tenantId) ? tenantsNotSkippingWeek : null
                );
            })
            .collect(Collectors.toList());

        return new WeeklyChores()
            .setWeekId(weekId)
            .setChores(distributedChoreList)
            .setRotation(rotation);
    }

    private Chore createChore(String weekId, String type, Long tenantId, Set<Long> tenantIdListOverride) {
        List<Long> asigneeListIds = new ArrayList<>();

        if (tenantIdListOverride == null || tenantIdListOverride.isEmpty()) {
            asigneeListIds.add(tenantId);
        } else {
            asigneeListIds.addAll(tenantIdListOverride);
        }

        var asigneeListUsernames = asigneeListIds.stream()
            .map(tenantsService::getTenantById)
            .map(Tenant::getUsername)
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

    public void completeWeeklyChores(String weekId, String choreType, Long tenantId) {
        weeklyChoresRepository.completeWeeklyChores(weekId, choreType, tenantId);
    }
}
