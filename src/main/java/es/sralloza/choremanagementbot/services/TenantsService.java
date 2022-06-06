package es.sralloza.choremanagementbot.services;

import es.sralloza.choremanagementbot.builders.TenantMapper;
import es.sralloza.choremanagementbot.exceptions.ConflictException;
import es.sralloza.choremanagementbot.exceptions.NotFoundException;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.db.DBTenant;
import es.sralloza.choremanagementbot.models.io.TenantCreate;
import es.sralloza.choremanagementbot.repositories.db.DBSkippedWeekRepository;
import es.sralloza.choremanagementbot.repositories.db.DBTenantsRepository;
import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.UUID;
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
                .orElseThrow(() -> getNotFoundException(tenantId));
    }

    public String getTenantsHash() {
        Set<Integer> tenantIds = listTenants().stream()
                .map(Tenant::getTelegramId)
                .collect(Collectors.toSet());
        return DigestUtils.sha256Hex(tenantIds.toString());
    }

    public Tenant createTenant(TenantCreate tenantCreate) {
        if (repository.existsById(tenantCreate.getTelegramId())) {
            throw new ConflictException("Tenant with id " + tenantCreate.getTelegramId() + " already exists");
        }
        String uuid = UUID.randomUUID().toString();
        var tenant = new DBTenant(tenantCreate.getTelegramId(), tenantCreate.getUsername(), uuid);
        repository.save(tenant);
        return mapper.build(tenant);
    }

    public void deleteTenantById(Integer tenantId) {
        if (!repository.existsById(tenantId)) {
            throw getNotFoundException(tenantId);
        }
        repository.deleteById(tenantId);

        var skippedWeeks = dbSkippedWeekRepository.findAll().stream()
                .filter(week -> week.getTenantId().equals(tenantId))
                .collect(Collectors.toList());
        dbSkippedWeekRepository.deleteAll(skippedWeeks);
    }

    private NotFoundException getNotFoundException(Integer tenantId) {
        return new NotFoundException("No tenant found with id " + tenantId);
    }

    public Tenant recreateTenantToken(Integer id) {
        Tenant tenant = getTenantById(id);
        UUID uuid = UUID.randomUUID();
        tenant.setApiToken(uuid);
        repository.save(mapper.build(tenant));
        return tenant;
    }
}
