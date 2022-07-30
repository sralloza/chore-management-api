package es.sralloza.choremanagementbot.security;

import es.sralloza.choremanagementbot.exceptions.ForbiddenException;
import es.sralloza.choremanagementbot.services.TenantsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;

@Service
public class SimpleSecurity {
  @Value("${admin-token}")
  private String principalRequestValue;

  @Autowired
  private HttpServletRequest request;

  @Autowired
  private TenantsService tenantsService;

  public void requireAdmin() {
    if (!isAdmin()) {
      throw new ForbiddenException("Admin access required");
    }
  }

  public void requireTenant() {
    if (!isTenant()) {
      throw new ForbiddenException("Tenant access required");
    }
  }

  private String getApiKey() {
    return request.getHeader("x-token");
  }

  private boolean isAdmin() {
    return principalRequestValue.equals(getApiKey());
  }

  private boolean isTenant() {
    if (isAdmin()) {
      return true;
    }
    return tenantsService.listTenants().stream()
        .anyMatch(t -> t.getApiToken().toString().equals(getApiKey()));
  }
}
