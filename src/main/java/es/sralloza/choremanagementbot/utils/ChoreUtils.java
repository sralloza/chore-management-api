package es.sralloza.choremanagementbot.utils;

import es.sralloza.choremanagementbot.models.custom.Chore;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
public class ChoreUtils {
    public List<Chore> rotate(List<Chore> originalChoreList, String newWeekId) {
        List<List<Integer>> newAssignees = originalChoreList.stream()
                .map(Chore::getOriginalAssigned)
                .collect(Collectors.toList());
        List<String> types = originalChoreList.stream()
                .map(Chore::getType)
                .collect(Collectors.toList());

        Collections.rotate(types, 1);

        return IntStream.range(0, types.size())
                .mapToObj(n -> createChore(newWeekId, newAssignees.get(n), types.get(n)))
                .sorted(Comparator.comparing(Chore::getType))
                .collect(Collectors.toList());
    }

    private Chore createChore(String newWeekId, List<Integer> assignees, String type) {
        return new Chore(newWeekId, type, assignees, assignees, false);
    }
}
