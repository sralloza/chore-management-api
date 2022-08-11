package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.builders.ChoreTypesMapper;
import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.exceptions.ConflictException;
import es.sralloza.choremanagementapi.exceptions.NotFoundException;
import es.sralloza.choremanagementapi.models.custom.ChoreType;
import es.sralloza.choremanagementapi.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementapi.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementapi.repositories.db.DBChoresRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.function.Supplier;
import java.util.stream.Collectors;

@Service
public class ChoreTypesService {
    @Autowired
    private DBChoreTypesRepository repository;
    @Autowired
    private TicketsService ticketsService;
    @Autowired
    private ChoreTypesMapper mapper;
    @Autowired
    private DBChoresRepository dbChoresRepository;

    public List<ChoreType> listChoreTypes() {
        return repository.findAll().stream()
                .map(mapper::build)
                .collect(Collectors.toList());
    }

    public ChoreType getChoreTypeById(String choreTypeId) {
        return getChoreTypeById(choreTypeId, getNotFoundException(choreTypeId));
    }

    public ChoreType getChoreTypeById(String id, Supplier<? extends RuntimeException> exceptionSupplier) {
        return mapper.build(repository.findById(id)
                .orElseThrow(exceptionSupplier));
    }

    public ChoreType createChoreType(ChoreType choreType) {
        if (repository.existsById(choreType.getId())) {
            throw new ConflictException("Chore type already exists with id " + choreType.getId());
        }

        ticketsService.createTicketsForChoreType(choreType.getId());
        return mapper.build(repository.save(mapper.build(choreType)));
    }

    public void deleteChoreType(String id) {
        if (!repository.existsById(id)) {
            throw getNotFoundException(id).get();
        }

        Optional<ChoreTypeTickets> tickets = ticketsService.getChoreTypeTicketsById(id);
        if (tickets.isPresent()) {
            var ticketsMap = tickets.get().getTicketsByTenant();
            for (var entry : ticketsMap.entrySet()) {
                if (entry.getValue() != 0) {
                    throw new BadRequestException("Chore type has unbalanced tickets");
                }
            }
        }

        var pendingChores = dbChoresRepository.findAll().stream()
                .filter(dbChore -> dbChore.getChoreType().equals(id))
                .filter(dbChore -> dbChore.getDone().equals(false))
                .count();
        if (pendingChores != 0) {
            throw new BadRequestException("Chore type " + id + " has " + pendingChores + " pending chores");
        }


        repository.deleteById(id);
    }

    private Supplier<NotFoundException> getNotFoundException(String id) {
        return () -> new NotFoundException("No chore type found with id " + id);
    }
}
