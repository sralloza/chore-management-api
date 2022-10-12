package es.sralloza.choremanagementapi.security;

import es.sralloza.choremanagementapi.exceptions.ForbiddenException;
import es.sralloza.choremanagementapi.exceptions.UnauthorizedException;
import es.sralloza.choremanagementapi.models.custom.Flat;
import es.sralloza.choremanagementapi.models.custom.User;
import es.sralloza.choremanagementapi.services.FlatsService;
import es.sralloza.choremanagementapi.services.UsersService;
import es.sralloza.choremanagementapi.utils.UserIdHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import java.util.Optional;

@Service
public class SimpleSecurity {
    @Autowired
    @Value("${admin-token}")
    private String principalRequestValue;

    @Autowired
    private HttpServletRequest request;
    @Autowired
    private UsersService usersService;
    @Autowired
    private FlatsService flatsService;
    @Autowired
    private UserIdHelper userIdHelper;

    public void requireAdmin() {
        if (!isAdmin()) {
            throw new ForbiddenException("Admin access required");
        }
    }

    public void requireUser() {
        if (!isUser()) {
            throw new ForbiddenException("User access required");
        }
    }

    public String getFlatName() {
        if (isAdmin()) {
            return request.getHeader("X-Flat");
        }
        var apiKey = getApiKey();
        if (isFlatOwner()) {
            return flatsService.getFlatByApiKey(apiKey)
                .map(Flat::getName)
                .orElse(null);
        }

        return usersService.listUsers().stream()
            .filter(user -> user.getApiKey().toString().equals(apiKey))
            .findAny()
            .map(User::getFlatName)
            .orElse(null);
    }

    public User getUser() {
        var apiKey = getApiKey();
        return usersService.listUsers().stream()
            .filter(t -> t.getApiKey().toString().equals(apiKey))
            .findAny()
            .orElse(null);
    }

    public void requireUserFromPath(String userId) {
        requireUser();
        var realUserId = getUser();
        var askedUserId = userIdHelper.parseUserId(userId);
        if (realUserId != null) {
            if (!askedUserId.equals(realUserId.getUserId())) {
                throw new ForbiddenException("You don't have permission to access other user's data");
            }
        }
    }

    public boolean isAdmin() {
        return principalRequestValue.equals(getApiKey());
    }

    public boolean isFlatOwner() {
        var apiKey = getApiKey();
        return flatsService.listFlats().stream().anyMatch(t -> t.getApiKey().toString().equals(apiKey));
    }

    public boolean isUser() {
        var apiKey = getApiKey();
        return usersService.listUsers().stream().anyMatch(t -> t.getApiKey().toString().equals(apiKey));
    }

    private String getApiKey() {
        return Optional.ofNullable(request.getHeader("x-token"))
            .orElseThrow(() -> new UnauthorizedException("Missing API key"));
    }
}
