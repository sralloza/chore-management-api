package es.sralloza.choremanagementbot.services;

import es.sralloza.choremanagementbot.exceptions.ForbiddenException;
import es.sralloza.choremanagementbot.exceptions.NotFoundException;
import es.sralloza.choremanagementbot.models.custom.ChoreType;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.db.DBChore;
import es.sralloza.choremanagementbot.repositories.db.DBChoresRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;

@Service
@Transactional
public class TransferChoresService {
    @Autowired
    private TenantsService tenantsService;
    @Autowired
    private TicketsService ticketsService;
    @Autowired
    private ChoreTypesService choreTypesService;
    @Autowired
    private DBChoresRepository dbChoresRepository;

    public void transfer(Integer from, Integer to, String choreTypeId, String weekId) {
        Tenant tenantOrigin = tenantsService.getTenantById(from);
        Tenant tenantDestiny = tenantsService.getTenantById(to);
        ChoreType choreType = choreTypesService.getChoreTypeById(choreTypeId);

        DBChore originalChore = dbChoresRepository.findAll().stream()
                .filter(dbChore -> dbChore.getChoreType().equals(choreType.getId()))
                .filter(dbChore -> dbChore.getWeekId().equals(weekId))
                .findAny()
                .orElseThrow(() -> new NotFoundException("Chore not found"));

        if (!originalChore.getTenantId().equals(tenantOrigin.getTenantId())) {
            var originalTenantName = tenantsService.getTenantById(originalChore.getTenantId()).getUsername();
            var msg = "You can't transfer chores from other tenants, " + "chore with type " + choreType.getId() +
                    " from week " + weekId + " is assigned to " + originalTenantName;
            throw new ForbiddenException(msg);
        }

        ticketsService.addTicketsToTenant(from, choreType, -1);
        ticketsService.addTicketsToTenant(to, choreType, 1);
        originalChore.setTenantId(tenantDestiny.getTenantId());
    }
}
