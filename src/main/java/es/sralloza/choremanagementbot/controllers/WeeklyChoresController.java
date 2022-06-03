package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.repositories.custom.WeeklyChoresRepository;
import es.sralloza.choremanagementbot.services.WeeklyChoresService;
import org.springframework.beans.factory.annotation.Autowired;
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

    @GetMapping("")
    public List<WeeklyChores> getWeeklyChores() {
        return service.findAll();
    }

    @GetMapping("/{weekId}")
    public Optional<WeeklyChores> getWeeklyChoresById(@PathVariable("weekId") String weekId) {
        return service.getByWeekId(weekId);
    }

    @PostMapping("/create")
    public WeeklyChores createWeeklyChores() {
        return service.createWeeklyChores();
    }

    @PostMapping("/create/week/{weekId}")
    public WeeklyChores createWeeklyChores(@PathVariable("weekId") String weekId) {
        return service.createWeeklyChores(weekId);
    }
}
