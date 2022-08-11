package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.custom.Tenant;
import es.sralloza.choremanagementapi.models.db.DBTenant;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class TenantMapper {
    public Tenant build(DBTenant dbTenant) {
        return new Tenant()
            .setTenantId(dbTenant.getTenantId())
            .setUsername(dbTenant.getUsername())
            .setApiToken(UUID.fromString(dbTenant.getApiToken()));
    }

    public DBTenant build(Tenant tenant) {
        return new DBTenant()
            .setTenantId(tenant.getTenantId())
            .setUsername(tenant.getUsername())
            .setApiToken(tenant.getApiToken().toString());
    }
}
