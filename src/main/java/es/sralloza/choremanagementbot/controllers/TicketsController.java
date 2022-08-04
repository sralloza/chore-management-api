package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementbot.security.SimpleSecurity;
import es.sralloza.choremanagementbot.services.TicketsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/v1/tickets")
public class TicketsController {
    @Autowired
    private TicketsService service;
    @Autowired
    private SimpleSecurity security;

    @GetMapping()
    public List<ChoreTypeTickets> listTickets() {
        security.requireTenant();
        return service.listChoreTypeTickets();
    }
}
