package es.sralloza.choremanagementbot.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/skip-weeks")
public class SkipWeeksController {
    @Autowired
    private SkipWeeksService service;

    @PostMapping("/tenant/{tenantId}/week/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void skipWeek(@PathVariable("weekId") String weekId,
                         @PathVariable("tenantId") Integer tenantId) {
        service.skipWeek(weekId, tenantId);
    }

    @DeleteMapping("/tenant/{tenantId}/week/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void unSkipWeek(@PathVariable("weekId") String weekId,
                           @PathVariable("tenantId") Integer tenantId) {
        service.unSkipWeek(weekId, tenantId);
    }
}
