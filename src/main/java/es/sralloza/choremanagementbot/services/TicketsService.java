package es.sralloza.choremanagementbot.services;

import es.sralloza.choremanagementbot.builders.ChoreTypeTicketsMapper;
import es.sralloza.choremanagementbot.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementbot.models.db.DBTicket;
import es.sralloza.choremanagementbot.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementbot.repositories.db.DBTicketsRepository;
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
    private TenantsService tenantsService;

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

    public void createTicketsForTenant(Integer tenantId) {
        dbTicketsRepository.saveAll(dbChoreTypesRepository.findAll().stream()
                .map(choreType -> new DBTicket(null, choreType.getId(), tenantId, 0))
                .collect(Collectors.toList()));
    }

    public void createTicketsForChoreType(String choreTypeId) {
        dbTicketsRepository.saveAll(tenantsService.listTenants().stream()
                .map(tenant -> new DBTicket(null, choreTypeId, tenant.getTenantId(), 0))
                .collect(Collectors.toList()));
    }

    public void addTicketsToTenant(Integer tenantId, String choreType, int nTickets) {
        DBTicket tickets = dbTicketsRepository.findAll().stream()
                .filter(dbTicket -> dbTicket.getChoreType().equals(choreType))
                .filter(dbTicket -> dbTicket.getTenantId().equals(tenantId))
                .findAny()
                .orElseThrow(() -> new RuntimeException("No tickets found for tenant with id " + tenantId +
                        " and chore type " + choreType));
        tickets.setTickets(tickets.getTickets() + nTickets);
        dbTicketsRepository.save(tickets);
    }

    public void deleteTicketsByTenant(Integer tenantId) {
        var tickets = dbTicketsRepository.findAll().stream()
                .filter(ticket -> ticket.getTenantId().equals(tenantId))
                .collect(Collectors.toList());
        dbTicketsRepository.deleteAll(tickets);
    }
}
