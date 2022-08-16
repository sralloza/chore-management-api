package es.sralloza.choremanagementapi.controllers;

import es.sralloza.choremanagementapi.models.custom.Tenant;
import es.sralloza.choremanagementapi.models.custom.WeeklyChores;
import es.sralloza.choremanagementapi.security.SimpleSecurity;
import es.sralloza.choremanagementapi.services.WeeklyChoresService;
import es.sralloza.choremanagementapi.utils.WeekIdHelper;
import es.sralloza.choremanagementapi.validator.WeekIdValidator;
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
    @Autowired
    private SimpleSecurity security;
    @Autowired
    private WeekIdHelper weekIdHelper;

    @GetMapping()
    public List<WeeklyChores> listWeeklyChores(@QueryParam("missingOnly") Boolean missingOnly) {
        security.requireTenant();
        return service.findAll(missingOnly);
    }

    @GetMapping("/{weekId}")
    public WeeklyChores getWeeklyChores(@PathVariable("weekId") String weekId) {
        weekId = weekIdHelper.parseWeekId(weekId);
        validator.validateSyntax(weekId);
        security.requireTenant();
        return service.getByWeekIdOr404(weekId);
    }

    @PostMapping("/{weekId}")
    public WeeklyChores createWeeklyChores(@PathVariable("weekId") String weekId,
                                           @QueryParam("force") Boolean force) {
        weekId = weekIdHelper.parseWeekId(weekId);
        validator.validateSyntax(weekId);
        validator.validateTimeline(weekId);
        security.requireAdmin();
        return service.createWeeklyChores(weekId, force);
    }

    @DeleteMapping("/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void deleteWeeklyChores(@PathVariable("weekId") String weekId) {
        weekId = weekIdHelper.parseWeekId(weekId);
        validator.validateSyntax(weekId);
        security.requireAdmin();
        service.deleteWeeklyChores(weekId);
    }

    @PostMapping("/{weekId}/choreType/{choreType}/complete")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void completeWeeklyChores(@PathVariable("weekId") String weekId,
                                     @PathVariable("choreType") String choreType) {
        weekId = weekIdHelper.parseWeekId(weekId);
        validator.validateSyntax(weekId);
        security.requireTenant();
        var tenantId = Optional.ofNullable(security.getTenant())
            .map(Tenant::getTenantId)
            .orElse(null);
        service.completeWeeklyChores(weekId, choreType, tenantId);
    }
}
