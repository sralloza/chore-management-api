package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.io.TenantCreate;
import es.sralloza.choremanagementbot.services.TenantsService;
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
    private TenantsService service;

    @GetMapping()
    public List<Tenant> listTenants() {
        return service.listTenants();
    }

    @PostMapping()
    public Tenant createTenant(@RequestBody TenantCreate tenantCreate) {
        return service.createTenant(tenantCreate);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = NO_CONTENT)
    public void deleteTenant(@PathVariable("id") Integer tenantId) {
        service.deleteTenantById(tenantId);
    }
}
