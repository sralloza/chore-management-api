package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
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
