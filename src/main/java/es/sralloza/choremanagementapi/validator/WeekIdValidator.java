package es.sralloza.choremanagementapi.validator;

import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.models.custom.WeeklyChores;
import es.sralloza.choremanagementapi.repositories.custom.WeeklyChoresRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


@Component
public class WeekIdValidator {
    @Autowired
    private WeeklyChoresRepository weeklyChoresRepository;

    public void validateSyntax(String weekId) {
        if (!isSyntaxValid(weekId)) {
            throw new BadRequestException("Invalid week ID: " + weekId);
        }
    }

    public void validateTimeline(String weekId) {
        if (!isWeekIdTheLatest(weekId)) {
            throw new BadRequestException("Invalid week ID (too old): " + weekId);
        }
    }

    private boolean isSyntaxValid(String weekId) {
        if (!weekId.matches("^[0-9]{4}\\.[0-9]{2}$")) {
            return false;
        }
        int weekNum = Integer.parseInt(weekId.split("\\.")[1]);
        return weekNum >= 1 && weekNum <= 53;
    }

    private boolean isWeekIdTheLatest(String weekId) {
        return weeklyChoresRepository.findAll().stream()
                .map(WeeklyChores::getWeekId)
                .max(String::compareTo)
                .map(latestWeekId -> latestWeekId.compareTo(weekId) <= 0)
                .orElse(true);
    }
}
