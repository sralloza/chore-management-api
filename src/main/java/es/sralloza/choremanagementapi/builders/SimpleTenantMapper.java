package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.custom.SimpleTenant;
import es.sralloza.choremanagementapi.models.custom.Tenant;
import es.sralloza.choremanagementapi.models.db.DBTenant;
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
