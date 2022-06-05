package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.db.DBTenant;
import es.sralloza.choremanagementbot.models.io.TenantCreate;
import es.sralloza.choremanagementbot.repositories.db.DBSkippedWeekRepository;
import es.sralloza.choremanagementbot.repositories.db.DBTenantsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import static org.springframework.http.HttpStatus.NO_CONTENT;

@RestController
@RequestMapping("/tenants")
public class TenantsController {
    @Autowired
    private DBTenantsRepository dbTenantsRepository;
    @Autowired
    private DBSkippedWeekRepository dbSkippedWeekRepository;

    @GetMapping()
    public List<DBTenant> listTenants() {
        return dbTenantsRepository.findAll();
    }

    @PostMapping()
    public DBTenant createTenant(@RequestBody TenantCreate tenantCreate) {
        var tenant = new DBTenant(tenantCreate.getTelegramId(), tenantCreate.getUsername(), UUID.randomUUID());
        return dbTenantsRepository.save(tenant);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = NO_CONTENT)
    public void deleteTenant(@PathVariable("id") Integer tenantId) {
        dbTenantsRepository.deleteById(tenantId);
        var skippedWeeks = dbSkippedWeekRepository.findAll().stream()
                .filter(week -> week.getTenantId().equals(tenantId))
                .collect(Collectors.toList());
        dbSkippedWeekRepository.deleteAll(skippedWeeks);
    }
}
