package es.sralloza.choremanagementapi.controllers;

import es.sralloza.choremanagementapi.models.custom.WeekId;
import es.sralloza.choremanagementapi.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/week-id")
public class WeekIdController {
    @Autowired
    private DateUtils dateUtils;

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
