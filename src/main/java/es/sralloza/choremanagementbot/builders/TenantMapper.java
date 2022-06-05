package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.db.DBTenant;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class TenantMapper {
    public Tenant build(DBTenant dbTenant) {
        return new Tenant()
                .setTelegramId(dbTenant.getTelegramId())
                .setUsername(dbTenant.getUsername())
                .setApiToken(UUID.fromString(dbTenant.getApiToken()));
    }
}
