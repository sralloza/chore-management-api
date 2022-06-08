package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.io.TenantCreate;
import es.sralloza.choremanagementbot.services.SkipWeeksService;
import es.sralloza.choremanagementbot.services.TenantsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.List;

import static org.springframework.http.HttpStatus.NO_CONTENT;

@RestController
@RequestMapping("/v1/tenants")
public class TenantsController {
    @Autowired
    private TenantsService tenantsService;
    @Autowired
    private SkipWeeksService skipWeeksService;

    @GetMapping()
    public List<Tenant> listTenants() {
        return tenantsService.listTenants();
    }

    @GetMapping("/{id}")
    public Tenant getTenant(@PathVariable Integer id) {
        return tenantsService.getTenantById(id);
    }

    @PostMapping()
    public Tenant createTenant(@RequestBody @Valid TenantCreate tenantCreate) {
        return tenantsService.createTenant(tenantCreate);
    }

    @PostMapping("/{id}/recreate-token")
    public Tenant recreateTenantToken(@PathVariable Integer id) {
        return tenantsService.recreateTenantToken(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = NO_CONTENT)
    public void deleteTenant(@PathVariable("id") Integer tenantId) {
        tenantsService.deleteTenantById(tenantId);
    }

    @PostMapping("/{tenantId}/skip/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void skipWeek(@PathVariable("weekId") String weekId,
                         @PathVariable("tenantId") Integer tenantId) {
        skipWeeksService.skipWeek(weekId, tenantId);
    }

    @PostMapping("/{tenantId}/unskip/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void unSkipWeek(@PathVariable("weekId") String weekId,
                           @PathVariable("tenantId") Integer tenantId) {
        skipWeeksService.unSkipWeek(weekId, tenantId);
    }
}
