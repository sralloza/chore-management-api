package es.sralloza.choremanagementbot.validator;

import es.sralloza.choremanagementbot.exceptions.BadRequestException;
import org.springframework.stereotype.Component;


@Component
public class WeekIdValidator {
    public void validate(String weekId) {
        if (!isWeekIdValid(weekId)) {
            throw new BadRequestException("Invalid week ID: " + weekId);
        }
    }

    private boolean isWeekIdValid(String weekId) {
        if (!weekId.matches("^[0-9]{4}.[0-9]{2}$")) {
            return false;
        }
        int weekNum = Integer.parseInt(weekId.split("\\.")[1]);
        return weekNum >= 1 && weekNum <= 53;
    }
}
