package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.WeekId;
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

    @GetMapping()
    public WeekId getCurrentWeekIdAlias() {
        return getCurrentWeekId();
    }

    @GetMapping("/current")
    public WeekId getCurrentWeekId() {
        return new WeekId(dateUtils.getCurrentWeekId());
    }

    @GetMapping("/last")
    public WeekId getLastWeekId() {
        return new WeekId(dateUtils.getWeekIdByDeltaDays(-7));
    }

    @GetMapping("/next")
    public WeekId getNextWeekId() {
        return new WeekId(dateUtils.getWeekIdByDeltaDays(7));
    }
}
