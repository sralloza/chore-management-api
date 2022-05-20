package builders;

import models.custom.Chore;
import models.db.DBChore;
import models.db.DBOriginalChore;

import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class ChoreMapper {
    public List<Chore> build(List<DBChore> dbChore, List<DBOriginalChore> originalChores) {
        Map<String, List<DBChore>> choresGroupedByWeekId = dbChore.stream()
                .collect(Collectors.groupingBy(DBChore::getWeekId));

        return buildDBChoresGroupedByWeekId(choresGroupedByWeekId, originalChores);
    }

    private List<Chore> buildDBChoresGroupedByWeekId(Map<String, List<DBChore>> chores,
                                                     List<DBOriginalChore> originalChores) {
        return chores.entrySet().stream()
                .map(entry -> {
                    Map<String, List<DBChore>> grouped = entry.getValue().stream()
                            .collect(Collectors.groupingBy(DBChore::getChoreType));
                    return buildChoresGroupedByChoreType(grouped, originalChores, entry.getKey());
                })
                .flatMap(Collection::stream)
                .sorted(Comparator.comparing(Chore::getWeekId)
                        .thenComparing(Chore::getType))
                .collect(Collectors.toList());
    }

    private List<Chore> buildChoresGroupedByChoreType(Map<String, List<DBChore>> choresGroupedByChoreType,
                                                      List<DBOriginalChore> originalChores,
                                                      String weekId) {
        return choresGroupedByChoreType.entrySet().stream()
                .map(entry -> new Chore()
                        .setType(entry.getKey())
                        .setAssigned(entry.getValue().stream()
                                .map(DBChore::getUserId)
                                .collect(Collectors.toList()))
                        .setOriginalAssigned(originalChores.stream()
                                .filter(choreOriginal -> choreOriginal.getChoreType().equals(entry.getKey()))
                                .filter(choreOriginal -> choreOriginal.getWeekId().equals(weekId))
                                .map(DBOriginalChore::getUserId)
                                .collect(Collectors.toList()))
                        .setWeekId(weekId)
                        .setDone(entry.getValue().stream().allMatch(DBChore::getDone)))
                .collect(Collectors.toList());
    }
}
