package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.db.DBChore;
import es.sralloza.choremanagementbot.services.TenantsService;
import org.hibernate.service.spi.InjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ChoreMapper {
    @Autowired
    private TenantsService tenantsService;

    public List<Chore> buildChore(List<DBChore> dbChore) {
        Map<String, List<DBChore>> choresGroupedByWeekId = dbChore.stream()
                .collect(Collectors.groupingBy(DBChore::getWeekId));

        return buildDBChoresGroupedByWeekId(choresGroupedByWeekId);
    }

    public List<DBChore> splitChore(Chore chore) {
        return chore.getAssignedIds().stream()
                .map(n -> new DBChore(null, chore.getType(), n, chore.getWeekId(), chore.getDone()))
                .collect(Collectors.toList());
    }

    private List<Chore> buildDBChoresGroupedByWeekId(Map<String, List<DBChore>> chores) {
        return chores.entrySet().stream()
                .map(entry -> {
                    Map<String, List<DBChore>> grouped = entry.getValue().stream()
                            .collect(Collectors.groupingBy(DBChore::getChoreType));
                    return buildChoresGroupedByChoreType(grouped, entry.getKey());
                })
                .flatMap(Collection::stream)
                .sorted(Comparator.comparing(Chore::getWeekId)
                        .thenComparing(Chore::getType))
                .collect(Collectors.toList());
    }

    private List<Chore> buildChoresGroupedByChoreType(Map<String, List<DBChore>> choresGroupedByChoreType,
                                                      String weekId) {
        return choresGroupedByChoreType.entrySet().stream()
                .map(entry -> new Chore()
                        .setType(entry.getKey())
                        .setAssignedIds(entry.getValue().stream()
                                .map(DBChore::getTenantId)
                                .collect(Collectors.toList()))
                        .setAssignedUsernames(entry.getValue().stream()
                                .map(DBChore::getTenantId)
                                .map(tenantsService::getTenantById)
                                .map(Tenant::getUsername)
                                .collect(Collectors.toList()))
                        .setWeekId(weekId)
                        .setDone(entry.getValue().stream().allMatch(DBChore::getDone)))
                .collect(Collectors.toList());
    }
}
