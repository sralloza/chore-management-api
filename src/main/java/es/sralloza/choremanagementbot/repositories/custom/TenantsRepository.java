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
    private DBTenantsRepository dbTenantsRepository;

    @Autowired
    private TenantMapper mapper;

    public List<Tenant> getAll() {
        return dbTenantsRepository.findAll().stream()
                .map(mapper::build)
                .collect(Collectors.toList());
    }
}
