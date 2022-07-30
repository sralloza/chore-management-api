package es.sralloza.choremanagementbot.security;

import es.sralloza.choremanagementbot.exceptions.ForbiddenException;
import es.sralloza.choremanagementbot.models.custom.Tenant;
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

  public Tenant getTenant() {
    var apiKey = getApiKey();
    return tenantsService.listTenants().stream()
        .filter(t -> t.getApiToken().toString().equals(apiKey))
        .findAny()
        .orElse(null);
  }

  public boolean isAdmin() {
    return principalRequestValue.equals(getApiKey());
  }

  public boolean isTenant() {
    if (isAdmin()) {
      return true;
    }
    return tenantsService.listTenants().stream()
        .anyMatch(t -> t.getApiToken().toString().equals(getApiKey()));
  }

  private String getApiKey() {
    return request.getHeader("x-token");
  }
}
