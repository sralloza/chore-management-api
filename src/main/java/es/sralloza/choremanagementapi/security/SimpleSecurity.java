package es.sralloza.choremanagementapi.security;

import es.sralloza.choremanagementapi.exceptions.ForbiddenException;
import es.sralloza.choremanagementapi.models.custom.Tenant;
import es.sralloza.choremanagementapi.services.TenantsService;
import es.sralloza.choremanagementapi.utils.TenantIdHelper;
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
  @Autowired
  private TenantIdHelper tenantIdHelper;

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

  public void requireTenantFromPath(String tenantId) {
    requireTenant();
    var userTenantId = getTenant();
    var askedTenantId = tenantIdHelper.parseTenantId(tenantId);
    if (userTenantId != null) {
      if (!askedTenantId.equals(userTenantId.getTenantId())) {
        throw new ForbiddenException("You don't have permission to access other tenant's data");
      }
    }
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
