package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.builders.ChoreTypeTicketsMapper;
import es.sralloza.choremanagementapi.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementapi.models.db.DBTicket;
import es.sralloza.choremanagementapi.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementapi.repositories.db.DBTicketsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class TicketsService {
    @Autowired
    private DBTicketsRepository dbTicketsRepository;
    @Autowired
    private DBChoreTypesRepository dbChoreTypesRepository;
    @Autowired
    private ChoreTypeTicketsMapper mapper;
    @Autowired
    private UsersService usersService;

    public List<ChoreTypeTickets> listChoreTypeTickets() {
        var tickets = dbTicketsRepository.findAll();
        return dbChoreTypesRepository.findAll().stream()
                .map(dbChoreType -> mapper.build(dbChoreType, tickets))
                .collect(Collectors.toList());
    }

    public Optional<ChoreTypeTickets> getChoreTypeTicketsById(String id) {
        return listChoreTypeTickets().stream()
                .filter(choreTypeTickets -> choreTypeTickets.getId().equals(id))
                .findAny();
    }

    public void createTicketsForUser(Long userId) {
        dbTicketsRepository.saveAll(dbChoreTypesRepository.findAll().stream()
                .map(choreType -> new DBTicket(null, choreType.getId(), userId, 0L))
                .collect(Collectors.toList()));
    }

    public void createTicketsForChoreType(String choreTypeId) {
        dbTicketsRepository.saveAll(usersService.listUsers().stream()
                .map(user -> new DBTicket(null, choreTypeId, user.getUserId(), 0L))
                .collect(Collectors.toList()));
    }

    public void addTicketsToUser(Long userId, String choreType, int nTickets) {
        DBTicket tickets = dbTicketsRepository.findAll().stream()
                .filter(dbTicket -> dbTicket.getChoreType().equals(choreType))
                .filter(dbTicket -> dbTicket.getUserId().equals(userId))
                .findAny()
                .orElseThrow(() -> new RuntimeException("No tickets found for user with id " + userId +
                        " and chore type " + choreType));
        tickets.setTickets(tickets.getTickets() + nTickets);
        dbTicketsRepository.save(tickets);
    }

    public void deleteTicketsByUser(Long userId) {
        var tickets = dbTicketsRepository.findAll().stream()
                .filter(ticket -> ticket.getUserId().equals(userId))
                .collect(Collectors.toList());
        dbTicketsRepository.deleteAll(tickets);
    }
}
