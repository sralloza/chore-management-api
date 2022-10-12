package es.sralloza.choremanagementapi.utils;

import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.security.SimpleSecurity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Nullable;

@Service
public class UserIdHelper {
    @Autowired
    private SimpleSecurity security;

    public Long parseUserId(String pathVariable) {
        return parseUserId(pathVariable, null);
    }

    public Long parseUserId(String pathVariable, @Nullable String pathName) {
        if (pathVariable.equals("me")) {
            if (security.isAdmin()) {
                throw new BadRequestException("Cannot use keyword me with an admin token");
            }
            return security.getUser().getUserId();
        }
        try {
            long userId = Long.parseLong(pathVariable);
            if (userId <= 0 && pathName != null) {
                throw new BadRequestException(pathName + " must be positive");
            }
            return userId;
        } catch (NumberFormatException e) {
            throw new BadRequestException("Invalid user id");
        }
    }
}
