package es.sralloza.choremanagementapi.controllers;

import es.sralloza.choremanagementapi.models.custom.User;
import es.sralloza.choremanagementapi.models.custom.Transfer;
import es.sralloza.choremanagementapi.models.io.TransferCreate;
import es.sralloza.choremanagementapi.security.SimpleSecurity;
import es.sralloza.choremanagementapi.services.TransferChoresService;
import es.sralloza.choremanagementapi.utils.UserIdHelper;
import es.sralloza.choremanagementapi.validator.WeekIdValidator;
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
    private UserIdHelper userIdHelper;

    @GetMapping()
    public List<Transfer> listTransfers() {
        security.requireUser();
        return service.listTransfers();
    }

    @GetMapping("/{id}")
    public Transfer getTransfer(@PathVariable Long id) {
        security.requireUser();
        return service.getTransferById(id);
    }

    @PostMapping("/start")
    public Transfer startTransfer(@RequestBody @Valid TransferCreate transferCreate) {
        weekIdValidator.validateSyntax(transferCreate.getWeekId());
        security.requireUser();
        security.requireUserFromPath(transferCreate.getUserIdFrom());
        var userIdFrom = Optional.ofNullable(security.getUser())
            .map(User::getUserId)
            .orElse(userIdHelper.parseUserId(transferCreate.getUserIdFrom(), "user_id_from"));

        return service.startTransfer(
            userIdFrom,
            transferCreate.getUserIdTo(),
            transferCreate.getChoreType(),
            transferCreate.getWeekId());
    }

    @PostMapping("/{id}/accept")
    public Transfer acceptTransfer(@PathVariable Long id) {
        security.requireUser();
        var transfer = service.getTransferById(id);
        security.requireUserFromPath(transfer.getUserIdTo().toString());
        return service.acceptTransfer(id);
    }

    @PostMapping("/{id}/reject")
    public Transfer rejectTransfer(@PathVariable Long id) {
        security.requireUser();
        var transfer = service.getTransferById(id);
        security.requireUserFromPath(transfer.getUserIdTo().toString());
        return service.rejectTransfer(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void deleteTransfer(@PathVariable("id") Long id) {
        service.deleteTransfer(id);
    }
}
