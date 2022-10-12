package es.sralloza.choremanagementapi.controllers;

import es.sralloza.choremanagementapi.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementapi.security.SimpleSecurity;
import es.sralloza.choremanagementapi.services.TicketsService;
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
        security.requireUser();
        return service.listChoreTypeTickets();
    }
}
