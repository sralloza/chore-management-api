package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.SimpleTenant;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.io.TenantCreate;
import es.sralloza.choremanagementbot.security.SimpleSecurity;
import es.sralloza.choremanagementbot.services.SkipWeeksService;
import es.sralloza.choremanagementbot.services.TenantsService;
import es.sralloza.choremanagementbot.utils.TenantIdHelper;
import es.sralloza.choremanagementbot.utils.WeekIdHelper;
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
    @Autowired
    private TenantIdHelper tenantIdHelper;
    @Autowired
    private WeekIdHelper weekIdHelper;
    @Autowired
    private SimpleSecurity security;

    @GetMapping()
    public List<Tenant> listTenants() {
        security.requireAdmin();
        return tenantsService.listTenants();
    }

    @GetMapping("/{id}")
    public SimpleTenant getTenant(@PathVariable String id) {
        security.requireTenantFromPath(id);
        Long askedTenantId = tenantIdHelper.parseTenantId(id);
        return tenantsService.getSimpleTenantById(askedTenantId);
    }

    @PostMapping()
    public Tenant createTenant(@RequestBody @Valid TenantCreate tenantCreate) {
        security.requireAdmin();
        return tenantsService.createTenant(tenantCreate);
    }

    @PostMapping("/{id}/recreate-token")
    public Tenant recreateTenantToken(@PathVariable String id) {
        security.requireTenantFromPath(id);
        Long askedTenantId = tenantIdHelper.parseTenantId(id);
        return tenantsService.recreateTenantToken(askedTenantId);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = NO_CONTENT)
    public void deleteTenant(@PathVariable("id") Long tenantId) {
        security.requireAdmin();
        tenantsService.deleteTenantById(tenantId);
    }

    @PostMapping("/{tenantId}/skip/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void skipWeek(@PathVariable("weekId") String weekId,
                         @PathVariable("tenantId") String tenantId) {
        weekId = weekIdHelper.parseWeekId(weekId);
        security.requireTenantFromPath(tenantId);
        var askedTenantId = tenantIdHelper.parseTenantId(tenantId);
        skipWeeksService.skipWeek(weekId, askedTenantId);
    }

    @PostMapping("/{tenantId}/unskip/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void unSkipWeek(@PathVariable("weekId") String weekId,
                           @PathVariable("tenantId") String tenantId) {
        weekId = weekIdHelper.parseWeekId(weekId);
        security.requireTenantFromPath(tenantId);
        var askedTenantId = tenantIdHelper.parseTenantId(tenantId);
        skipWeeksService.unSkipWeek(weekId, askedTenantId);
    }
}
