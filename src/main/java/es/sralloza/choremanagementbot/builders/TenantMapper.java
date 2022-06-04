package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.db.DBTenant;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TenantMapper {
    public Tenant build(DBTenant dbTenant, List<Chore> chores) {
        var userPendingChores = chores.stream()
                .filter(chore -> chore.getAssigned().contains(dbTenant.getTelegramId()))
                .filter(chore -> !chore.getDone())
                .collect(Collectors.toList());
        return new Tenant()
                .setTelegramId(dbTenant.getTelegramId())
                .setUsername(dbTenant.getUsername())
                .setApiToken(dbTenant.getApiToken())
                .setPendingChores(userPendingChores);
    }
}
