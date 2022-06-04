package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/week-id")
public class WeekIdController {
    @Autowired
    private DateUtils dateUtils;

    @GetMapping("")
    public String getCurrentWeekIdAlias() {
        return getCurrentWeekId();
    }

    @GetMapping("/current")
    public String getCurrentWeekId() {
        return dateUtils.getCurrentWeekId();
    }

    @GetMapping("/last")
    public String getLastWeekId() {
        return dateUtils.getWeekIdByDeltaDays(-7);
    }

    @GetMapping("/next")
    public String getNextWeekId() {
        return dateUtils.getWeekIdByDeltaDays(7);
    }
}
