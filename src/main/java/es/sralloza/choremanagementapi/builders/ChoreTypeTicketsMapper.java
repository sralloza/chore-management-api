package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementapi.models.db.DBChoreType;
import es.sralloza.choremanagementapi.models.db.DBTicket;
import es.sralloza.choremanagementapi.services.UsersService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ChoreTypeTicketsMapper {
    @Autowired
    private UsersService usersService;

    private String dbTicketToUserUsername(DBTicket dbTicket) {
        return usersService.getUserById(dbTicket.getUserId()).getUsername();
    }

    public ChoreTypeTickets build(DBChoreType dbChoreType, List<DBTicket> tickets) {
        Map<String, Long> tickestByUser = tickets.stream()
                .filter(dbTicket -> dbTicket.getChoreType().equals(dbChoreType.getId()))
                .collect(Collectors.toMap(this::dbTicketToUserUsername, DBTicket::getTickets));
        return new ChoreTypeTickets()
                .setId(dbChoreType.getId())
                .setDescription(dbChoreType.getDescription())
                .setTicketsByUser(tickestByUser);
    }
}
