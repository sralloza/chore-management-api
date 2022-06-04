package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.services.WeeklyChoresService;
import es.sralloza.choremanagementbot.validator.WeekIdValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/weekly-chores")
public class WeeklyChoresController {
    @Autowired
    private WeeklyChoresService service;
    @Autowired
    private WeekIdValidator validator;

    @GetMapping()
    public List<WeeklyChores> getWeeklyChores() {
        return service.findAll();
    }

    @GetMapping("/{weekId}")
    public Optional<WeeklyChores> getWeeklyChoresById(@PathVariable("weekId") String weekId) {
        validator.validateSyntax(weekId);
        return service.getByWeekId(weekId);
    }

    @PostMapping()
    public WeeklyChores createNextWeekChores() {
        return service.createNextWeekChores();
    }

    @PostMapping("/week/{weekId}")
    public WeeklyChores createWeeklyChores(@PathVariable("weekId") String weekId) {
        validator.validateSyntax(weekId);
        validator.validateTimeline(weekId);
        return service.createWeeklyChores(weekId);
    }

    @DeleteMapping("/{weekId}")
    public void deleteWeeklyChores(@PathVariable("weekId") String weekId) {
        validator.validateSyntax(weekId);
        service.deleteWeeklyChores(weekId);
    }
}
