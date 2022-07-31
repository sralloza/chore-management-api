package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.SimpleTenant;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.db.DBTenant;
import org.springframework.stereotype.Service;

@Service
public class SimpleTenantMapper {
    public SimpleTenant build(Tenant tenant) {
        return new SimpleTenant()
            .setTenantId(tenant.getTenantId())
            .setUsername(tenant.getUsername());
    }

    public SimpleTenant build(DBTenant dbTenant) {
        return new SimpleTenant()
            .setTenantId(dbTenant.getTenantId())
            .setUsername(dbTenant.getUsername());
    }
}
