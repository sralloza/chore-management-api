package es.sralloza.choremanagementbot.services;

import es.sralloza.choremanagementbot.builders.TenantMapper;
import es.sralloza.choremanagementbot.exceptions.NotFoundException;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.db.DBTenant;
import es.sralloza.choremanagementbot.models.io.TenantCreate;
import es.sralloza.choremanagementbot.repositories.db.DBSkippedWeekRepository;
import es.sralloza.choremanagementbot.repositories.db.DBTenantsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.function.Supplier;
import java.util.stream.Collectors;

@Service
public class TenantsService {
    @Autowired
    private DBTenantsRepository repository;
    @Autowired
    private DBSkippedWeekRepository dbSkippedWeekRepository;
    @Autowired
    private TenantMapper mapper;

    public List<Tenant> listTenants() {
        return repository.findAll().stream()
                .map(mapper::build)
                .collect(Collectors.toList());
    }

    public Tenant getTenantById(Integer tenantId) {
        return repository.findById(tenantId)
                .map(mapper::build)
                .orElseThrow(notFoundException(tenantId));
    }

    public Tenant createTenant(TenantCreate tenantCreate) {
        String uuid = UUID.randomUUID().toString();
        var tenant = new DBTenant(tenantCreate.getTelegramId(), tenantCreate.getUsername(), uuid);
        repository.save(tenant);
        return mapper.build(tenant);
    }

    public void deleteTenantById(Integer tenantId) {
        if (!repository.existsById(tenantId)) {
            throw notFoundException(tenantId).get();
        }
        repository.deleteById(tenantId);

        var skippedWeeks = dbSkippedWeekRepository.findAll().stream()
                .filter(week -> week.getTenantId().equals(tenantId))
                .collect(Collectors.toList());
        dbSkippedWeekRepository.deleteAll(skippedWeeks);
    }

    private Supplier<NotFoundException> notFoundException(Integer tenantId) {
        return () -> new NotFoundException("No tenant found with id " + tenantId);
    }
}
