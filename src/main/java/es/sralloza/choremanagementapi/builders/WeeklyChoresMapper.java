package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.custom.Chore;
import es.sralloza.choremanagementapi.models.custom.WeeklyChores;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class WeeklyChoresMapper {
    public WeeklyChores build(String weekId, List<Chore> choreList, Integer rotation) {
        return new WeeklyChores()
                .setWeekId(weekId)
                .setChores(choreList)
                .setRotation(rotation);
    }
}
