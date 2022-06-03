package es.sralloza.choremanagementbot.utils;

import es.sralloza.choremanagementbot.models.custom.Chore;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class ChoreUtils {
    public <T> List<T> repeatArray(List<T> input, int size) {
        List<T> result = new ArrayList<>();
        int i = 0;
        while (result.size() != size) {
            if (i >= input.size()) {
                i -= input.size();
            }
            result.add(input.get(i));
            i++;
        }
        return result;
    }
//    public List<Chore> rotate(List<Chore> originalChoreList, String newWeekId) {
//        List<List<Integer>> newAssignees = originalChoreList.stream()
//                .map(Chore::getOriginalAssigned)
//                .collect(Collectors.toList());
//        List<String> types = originalChoreList.stream()
//                .map(Chore::getType)
//                .collect(Collectors.toList());
//
//        Collections.rotate(types, 1);
//
//        return IntStream.range(0, types.size())
//                .mapToObj(n -> createChore(newWeekId, newAssignees.get(n), types.get(n)))
//                .sorted(Comparator.comparing(Chore::getType))
//                .collect(Collectors.toList());
//    }

    private Chore createChore(String newWeekId, List<Integer> assignees, String type) {
        return new Chore(newWeekId, type, assignees, false);
    }
}
