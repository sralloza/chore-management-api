package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.Transfer;
import es.sralloza.choremanagementbot.models.io.TransferCreate;
import es.sralloza.choremanagementbot.security.SimpleSecurity;
import es.sralloza.choremanagementbot.services.TransferChoresService;
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

@RestController
@RequestMapping("/v1/transfers")
public class TransferChoresController {
    @Autowired
    private TransferChoresService service;
    @Autowired
    private WeekIdValidator weekIdValidator;
    @Autowired
    private SimpleSecurity security;

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
        return service.startTransfer(transferCreate.getTenantIdFrom(),
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
        return service.rejectTransfer(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void deleteTransfer(@PathVariable("id") Long id) {
        service.deleteTransfer(id);
    }
}
