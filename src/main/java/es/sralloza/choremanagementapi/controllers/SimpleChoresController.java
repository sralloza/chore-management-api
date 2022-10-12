package es.sralloza.choremanagementapi.controllers;

import es.sralloza.choremanagementapi.models.SimpleChore;
import es.sralloza.choremanagementapi.security.SimpleSecurity;
import es.sralloza.choremanagementapi.services.SimpleChoresService;
import es.sralloza.choremanagementapi.utils.UserIdHelper;
import es.sralloza.choremanagementapi.utils.WeekIdHelper;
import es.sralloza.choremanagementapi.validator.WeekIdValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Nullable;
import javax.ws.rs.QueryParam;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/v1/simple-chores")
public class SimpleChoresController {
    @Autowired
    private SimpleChoresService service;
    @Autowired
    private UserIdHelper userIdHelper;
    @Autowired
    private WeekIdHelper weekIdHelper;
    @Autowired
    private WeekIdValidator weekIdValidator;
    @Autowired
    private SimpleSecurity security;

    @GetMapping("")
    public List<SimpleChore> listSimpleChores(@Nullable @QueryParam("choreType") String choreType,
                                              @Nullable @QueryParam("userId") String userId,
                                              @Nullable @QueryParam("weekId") String weekId,
                                              @Nullable @QueryParam("done") Boolean done
    ) {
        if (weekId != null) {
            weekIdValidator.validateSyntax(weekId);
        }
        Long realUserId = Optional.ofNullable(userId).map(userIdHelper::parseUserId).orElse(null);
        weekId = Optional.ofNullable(weekId).map(weekIdHelper::parseWeekId).orElse(null);
        security.requireUser();
        return service.listSimpleChores(choreType, realUserId, weekId, done);
    }
}
