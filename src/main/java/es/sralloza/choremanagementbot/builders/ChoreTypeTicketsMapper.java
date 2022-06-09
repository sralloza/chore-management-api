package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementbot.models.db.DBChoreType;
import es.sralloza.choremanagementbot.models.db.DBTicket;
import es.sralloza.choremanagementbot.services.TenantsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ChoreTypeTicketsMapper {
    @Autowired
    private TenantsService tenantsService;

    private String dbTicketToTenantUsername(DBTicket dbTicket) {
        return tenantsService.getTenantById(dbTicket.getTenantId()).getUsername();
    }

    public ChoreTypeTickets build(DBChoreType dbChoreType, List<DBTicket> tickets) {
        Map<String, Integer> ticketsByTenant = tickets.stream()
                .filter(dbTicket -> dbTicket.getChoreType().equals(dbChoreType.getId()))
                .collect(Collectors.toMap(this::dbTicketToTenantUsername, DBTicket::getTickets));
        return new ChoreTypeTickets()
                .setId(dbChoreType.getId())
                .setDescription(dbChoreType.getDescription())
                .setTicketsByTenant(ticketsByTenant);
    }
}
