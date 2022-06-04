package es.sralloza.choremanagementbot.repositories.custom;

import es.sralloza.choremanagementbot.builders.TenantMapper;
import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.repositories.db.DBTenantsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.stream.Collectors;

@Repository
public class TenantsRepository {
    @Autowired
    private final ChoresRepository choresRepository;
    @Autowired
    private final DBTenantsRepository dbTenantsRepository;
    @Autowired
    private final TenantMapper mapper;

    public TenantsRepository(ChoresRepository choresRepository,
                             DBTenantsRepository dbTenantsRepository,
                             TenantMapper mapper) {
        this.choresRepository = choresRepository;
        this.dbTenantsRepository = dbTenantsRepository;
        this.mapper = mapper;
    }

    public List<Tenant> getAll() {
        List<Chore> chores = choresRepository.getAll();
        return dbTenantsRepository.findAll().stream()
                .map(dbTenant -> mapper.build(dbTenant, chores))
                .collect(Collectors.toList());
    }
}
