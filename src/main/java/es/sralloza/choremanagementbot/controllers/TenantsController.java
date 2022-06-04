package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.db.DBTenant;
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

import static org.springframework.http.HttpStatus.NO_CONTENT;

@RestController
@RequestMapping("/tenants")
public class TenantsController {
    @Autowired
    private DBTenantsRepository dbTenantsRepository;

    @GetMapping()
    public List<DBTenant> listTenants() {
        return dbTenantsRepository.findAll();
    }

    @PostMapping()
    public DBTenant createTenant(@RequestBody DBTenant tenant) {
        return dbTenantsRepository.save(tenant);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = NO_CONTENT)
    public void deleteTenant(@PathVariable("id") Integer tenantId) {
        dbTenantsRepository.deleteById(tenantId);
    }
}
