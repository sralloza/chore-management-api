package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.builders.SimpleTenantMapper;
import es.sralloza.choremanagementapi.builders.TenantMapper;
import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.exceptions.ConflictException;
import es.sralloza.choremanagementapi.exceptions.NotFoundException;
import es.sralloza.choremanagementapi.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementapi.models.custom.SimpleTenant;
import es.sralloza.choremanagementapi.models.custom.Tenant;
import es.sralloza.choremanagementapi.models.db.DBTenant;
import es.sralloza.choremanagementapi.models.io.TenantCreate;
import es.sralloza.choremanagementapi.repositories.db.DBChoresRepository;
import es.sralloza.choremanagementapi.repositories.db.DBTenantsRepository;
import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Supplier;
import java.util.stream.Collectors;

@Service
public class TenantsService {
    @Autowired
    private DBTenantsRepository repository;
    @Autowired
    private SkipWeeksService skipWeeksService;
    @Autowired
    private TicketsService ticketsService;
    @Autowired
    private DBChoresRepository dbChoresRepository;
    @Autowired
    private TenantMapper tenantMapper;
    @Autowired
    private SimpleTenantMapper simpleTenantMapper;

    public List<Tenant> listTenants() {
        return repository.findAll().stream()
                .map(tenantMapper::build)
                .collect(Collectors.toList());
    }

    public SimpleTenant getSimpleTenantById(Long tenantId) {
        return simpleTenantMapper.build(getTenantById(tenantId));
    }

    public Tenant getTenantById(Long tenantId) {
        return getTenantById(tenantId, getNotFoundException(tenantId));
    }

    public Tenant getTenantById(Long tenantId, Supplier<? extends RuntimeException> exceptionSupplier) {
        return repository.findById(tenantId)
                .map(tenantMapper::build)
                .orElseThrow(exceptionSupplier);
    }

    public String getTenantsHash() {
        Set<Long> tenantIds = listTenants().stream()
                .map(Tenant::getTenantId)
                .collect(Collectors.toSet());
        return DigestUtils.sha256Hex(tenantIds.toString());
    }

    public Tenant createTenant(TenantCreate tenantCreate) {
        if (repository.existsById(tenantCreate.getTenantId())) {
            throw new ConflictException("Tenant with id " + tenantCreate.getTenantId() + " already exists");
        }
        String uuid = UUID.randomUUID().toString();
        var tenant = new DBTenant(tenantCreate.getTenantId(), tenantCreate.getUsername(), uuid);
        repository.save(tenant);
        ticketsService.createTicketsForTenant(tenant.getTenantId());
        return tenantMapper.build(tenant);
    }

    public void deleteTenantById(Long tenantId) {
        if (!repository.existsById(tenantId)) {
            throw getNotFoundException(tenantId).get();
        }

        Tenant tenant = getTenantById(tenantId);
        List<ChoreTypeTickets> tickets = ticketsService.listChoreTypeTickets();
        for (var choreTypeTickets : tickets) {
            Map<String, Long> ticketsMap = choreTypeTickets.getTicketsByTenant();
            if (ticketsMap.get(tenant.getUsername()) != 0) {
                throw new BadRequestException("Tenant has unbalanced tickets");
            }
        }

        var pendingChores = dbChoresRepository.findAll().stream()
                .filter(dbChore -> dbChore.getTenantId().equals(tenantId))
                .filter(dbChore -> dbChore.getDone().equals(false))
                .count();
        if (pendingChores != 0) {
            throw new BadRequestException("Tenant has " + pendingChores + " pending chores");
        }

        repository.deleteById(tenantId);

        skipWeeksService.deleteSkipWeeksByTenantId(tenantId);
        ticketsService.deleteTicketsByTenant(tenantId);
    }

    private Supplier<NotFoundException> getNotFoundException(Long tenantId) {
        return () -> new NotFoundException("No tenant found with id " + tenantId);
    }

    public Tenant recreateTenantToken(Long id) {
        Tenant tenant = getTenantById(id);
        UUID uuid = UUID.randomUUID();
        tenant.setApiToken(uuid);
        repository.save(tenantMapper.build(tenant));
        return tenant;
    }
}
