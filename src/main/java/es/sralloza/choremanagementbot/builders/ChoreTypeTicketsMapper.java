package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementbot.models.db.DBChoreType;
import es.sralloza.choremanagementbot.models.db.DBTicket;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ChoreTypeTicketsMapper {
    public ChoreTypeTickets build(DBChoreType dbChoreType, List<DBTicket> tickets) {
        var ticketsByTenant = tickets.stream()
                .filter(dbTicket -> dbTicket.getChoreType().equals(dbChoreType.getId()))
                .collect(Collectors.toMap(DBTicket::getUsername, DBTicket::getTickets));
        return new ChoreTypeTickets()
                .setId(dbChoreType.getId())
                .setDescription(dbChoreType.getDescription())
                .setTicketsByTenant(ticketsByTenant);
    }
}
