package es.sralloza.choremanagementbot.utils;

import es.sralloza.choremanagementbot.exceptions.BadRequestException;
import es.sralloza.choremanagementbot.security.SimpleSecurity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class TenantIdHelper {
  @Autowired
  private SimpleSecurity security;

  public Integer parseTenantId(String pathVariable) {
    if (pathVariable.equals("me")) {
      if (security.isAdmin()){
        throw new BadRequestException("Cannot use keyword me with an admin token");
      }
      return security.getTenant().getTenantId();
    }
    try {
      return Integer.parseInt(pathVariable);
    } catch (NumberFormatException e) {
      throw new BadRequestException("Invalid tenant id");
    }
  }
}
