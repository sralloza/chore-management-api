package builders;

import models.custom.ChoreTypeTickets;
import models.db.DBChoreType;
import models.db.DBTicket;

import java.util.List;
import java.util.stream.Collectors;

public class ChoreTypeTicketsMapper {
    public ChoreTypeTickets build(DBChoreType dbChoreType, List<DBTicket> tickets) {
        var ticketsByUser = tickets.stream()
                .filter(dbTicket -> dbTicket.getChoreType().equals(dbChoreType.getId()))
                .collect(Collectors.toMap(DBTicket::getUsername, DBTicket::getTickets));
        return new ChoreTypeTickets()
                .setId(dbChoreType.getId())
                .setDescription(dbChoreType.getDescription())
                .setTicketsByUser(ticketsByUser);
    }
}
