package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.custom.Transfer;
import es.sralloza.choremanagementbot.models.io.TransferCreate;
import es.sralloza.choremanagementbot.security.SimpleSecurity;
import es.sralloza.choremanagementbot.services.TransferChoresService;
import es.sralloza.choremanagementbot.utils.TenantIdHelper;
import es.sralloza.choremanagementbot.validator.WeekIdValidator;
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
import java.util.Optional;

@RestController
@RequestMapping("/v1/transfers")
public class TransferChoresController {
    @Autowired
    private TransferChoresService service;
    @Autowired
    private WeekIdValidator weekIdValidator;
    @Autowired
    private SimpleSecurity security;
    @Autowired
    private TenantIdHelper tenantIdHelper;

    @GetMapping()
    public List<Transfer> listTransfers() {
        security.requireTenant();
        return service.listTransfers();
    }

    @GetMapping("/{id}")
    public Transfer getTransfer(@PathVariable Long id) {
        security.requireTenant();
        return service.getTransferById(id);
    }

    @PostMapping("/start")
    public Transfer startTransfer(@RequestBody @Valid TransferCreate transferCreate) {
        weekIdValidator.validateSyntax(transferCreate.getWeekId());
        security.requireTenant();
        security.requireTenantFromPath(transferCreate.getTenantIdFrom());
        var tenantFrom = security.getTenant();
        var tenantIdFrom = Optional.ofNullable(tenantFrom)
            .map(Tenant::getTenantId)
            .orElse(tenantIdHelper.parseTenantId(transferCreate.getTenantIdFrom(), "tenant_id_from"));

        return service.startTransfer(
            tenantIdFrom,
            transferCreate.getTenantIdTo(),
            transferCreate.getChoreType(),
            transferCreate.getWeekId());
    }

    @PostMapping("/{id}/accept")
    public Transfer acceptTransfer(@PathVariable Long id) {
        security.requireTenant();
        var transfer = service.getTransferById(id);
        security.requireTenantFromPath(transfer.getTenantIdTo().toString());
        return service.acceptTransfer(id);
    }

    @PostMapping("/{id}/reject")
    public Transfer rejectTransfer(@PathVariable Long id) {
        security.requireTenant();
        var transfer = service.getTransferById(id);
        security.requireTenantFromPath(transfer.getTenantIdTo().toString());
        return service.rejectTransfer(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void deleteTransfer(@PathVariable("id") Long id) {
        service.deleteTransfer(id);
    }
}
