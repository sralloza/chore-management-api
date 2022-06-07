package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.services.WeeklyChoresService;
import es.sralloza.choremanagementbot.validator.WeekIdValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import javax.ws.rs.QueryParam;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/v1/weekly-chores")
public class WeeklyChoresController {
    @Autowired
    private WeeklyChoresService service;
    @Autowired
    private WeekIdValidator validator;

    @GetMapping()
    public List<WeeklyChores> listWeeklyChores() {
        return service.findAll();
    }

    @GetMapping("/{weekId}")
    public Optional<WeeklyChores> getWeeklyChores(@PathVariable("weekId") String weekId) {
        validator.validateSyntax(weekId);
        return service.getByWeekId(weekId);
    }

    @PostMapping()
    public WeeklyChores createNextWeekChores(@QueryParam("force") Boolean force) {
        return service.createNextWeekChores(force);
    }

    @PostMapping("/week/{weekId}")
    public WeeklyChores createWeeklyChores(@PathVariable("weekId") String weekId,
                                           @QueryParam("force") Boolean force) {
        validator.validateSyntax(weekId);
        validator.validateTimeline(weekId);
        return service.createWeeklyChores(weekId, force);
    }

    @DeleteMapping("/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void deleteWeeklyChores(@PathVariable("weekId") String weekId) {
        validator.validateSyntax(weekId);
        service.deleteWeeklyChores(weekId);
    }

    @PostMapping("/skip/{weekId}/tenant/{tenantId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void skipWeek(@PathVariable("weekId") String weekId,
                         @PathVariable("tenantId") Integer tenantId) {
        validator.validateSyntax(weekId);
        validator.validateTimeline(weekId);
        service.skipWeek(weekId, tenantId);
    }
}
