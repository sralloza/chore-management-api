package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.services.TransferChoresService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/transfer-chores")
public class TransferChoresController {
    @Autowired
    private TransferChoresService service;

    @PostMapping("/from/{from}/to/{to}/choreType/{choreType}/week/{weekId}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void transferChores(@PathVariable("from") Integer from,
                               @PathVariable("to") Integer to,
                               @PathVariable("choreType") String choreType,
                               @PathVariable("weekId") String weekId) {
        service.transfer(from, to, choreType, weekId);
    }
}
