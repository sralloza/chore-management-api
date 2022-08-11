package es.sralloza.choremanagementapi.utils;

import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.security.SimpleSecurity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Nullable;

@Service
public class TenantIdHelper {
    @Autowired
    private SimpleSecurity security;

    public Long parseTenantId(String pathVariable) {
        return parseTenantId(pathVariable, null);
    }

    public Long parseTenantId(String pathVariable, @Nullable String pathName) {
        if (pathVariable.equals("me")) {
            if (security.isAdmin()) {
                throw new BadRequestException("Cannot use keyword me with an admin token");
            }
            return security.getTenant().getTenantId();
        }
        try {
            long tenantId = Long.parseLong(pathVariable);
            if (tenantId <= 0 && pathName != null) {
                throw new BadRequestException(pathName + " must be positive");
            }
            return tenantId;
        } catch (NumberFormatException e) {
            throw new BadRequestException("Invalid tenant id");
        }
    }
}
