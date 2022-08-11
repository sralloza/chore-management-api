package es.sralloza.choremanagementapi.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class WeekIdHelper {
    @Autowired
    private DateUtils dateUtils;

    public String parseWeekId(String weekId) {
        weekId = weekId.toLowerCase();
        if (weekId.equals("next")) {
            return dateUtils.getNextWeekId();
        }
        if (weekId.equals("current")) {
            return dateUtils.getCurrentWeekId();
        }
        if (weekId.equals("last")) {
            return dateUtils.getLastWeekId();
        }
        return weekId;
    }
}
