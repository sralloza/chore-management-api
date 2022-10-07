package es.sralloza.choremanagementapi.controllers;

import es.sralloza.choremanagementapi.models.custom.SimpleUser;
import es.sralloza.choremanagementapi.models.custom.User;
import es.sralloza.choremanagementapi.models.io.UserCreate;
import es.sralloza.choremanagementapi.security.SimpleSecurity;
import es.sralloza.choremanagementapi.services.SkipWeeksService;
import es.sralloza.choremanagementapi.services.UsersService;
import es.sralloza.choremanagementapi.utils.UserIdHelper;
import es.sralloza.choremanagementapi.utils.WeekIdHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.List;

import static org.springframework.http.HttpStatus.NO_CONTENT;

@RestController
@RequestMapping("/v1/users")
public class UsersController {
    @Autowired
    private UsersService usersService;
    @Autowired
    private SkipWeeksService skipWeeksService;
    @Autowired
    private UserIdHelper userIdHelper;
    @Autowired
    private WeekIdHelper weekIdHelper;
    @Autowired
    private SimpleSecurity security;

    @GetMapping()
    public List<User> listUsers() {
        security.requireAdmin();
        return usersService.listUsers();
    }

    @GetMapping("/{id}")
    public SimpleUser getUser(@PathVariable String id) {
        security.requireUserFromPath(id);
        Long askedUserId = userIdHelper.parseUserId(id);
        return usersService.getSimpleUserById(askedUserId);
    }

    @PostMapping()
    public User createUser(@RequestBody @Valid UserCreate userCreate) {
        security.requireAdmin();
        return usersService.createUser(userCreate);
    }

    @PostMapping("/{id}/recreate-token")
    public User recreateUserToken(@PathVariable String id) {
        security.requireUserFromPath(id);
        Long askedUserId = userIdHelper.parseUserId(id);
        return usersService.recreateUserToken(askedUserId);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = NO_CONTENT)
    public void deleteUser(@PathVariable("id") Long id) {
        security.requireAdmin();
        usersService.deleteUserById(id);
    }

    @PostMapping("/{userId}/skip/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void skipWeek(@PathVariable("weekId") String weekId,
                         @PathVariable("userId") String userId) {
        weekId = weekIdHelper.parseWeekId(weekId);
        security.requireUserFromPath(userId);
        var askedUserId = userIdHelper.parseUserId(userId);
        skipWeeksService.skipWeek(weekId, askedUserId);
    }

    @PostMapping("/{userId}/unskip/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void unSkipWeek(@PathVariable("weekId") String weekId,
                           @PathVariable("userId") String userId) {
        weekId = weekIdHelper.parseWeekId(weekId);
        security.requireUserFromPath(userId);
        var askedUserId = userIdHelper.parseUserId(userId);
        skipWeeksService.unSkipWeek(weekId, askedUserId);
    }
}
