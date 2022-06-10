package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.Transfer;
import es.sralloza.choremanagementbot.models.io.TransferCreate;
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
import javax.ws.rs.QueryParam;
import java.util.List;

@RestController
@RequestMapping("/v1/transfers")
public class TransferChoresController {
    @Autowired
    private TransferChoresService service;
    @Autowired
    private WeekIdValidator weekIdValidator;

    @GetMapping()
    public List<Transfer> listTransfers() {
        return service.listTransfers();
    }

    @GetMapping("/{id}")
    public Transfer getTransfer(@PathVariable Long id) {
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

    @PostMapping("/complete/{id}")
    public Transfer completeTransfer(@PathVariable Long id) {
        return service.completeTransfer(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void deleteTransfer(@PathVariable("id") Long id) {
        service.deleteTransfer(id);
    }
}
