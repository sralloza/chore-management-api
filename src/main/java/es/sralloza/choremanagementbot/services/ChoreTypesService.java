package es.sralloza.choremanagementbot.services;

import es.sralloza.choremanagementbot.builders.ChoreTypesMapper;
import es.sralloza.choremanagementbot.exceptions.ConflictException;
import es.sralloza.choremanagementbot.exceptions.NotFoundException;
import es.sralloza.choremanagementbot.models.custom.ChoreType;
import es.sralloza.choremanagementbot.repositories.db.DBChoreTypesRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
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
        repository.deleteById(id);
    }

    private Supplier<NotFoundException> getNotFoundException(String id) {
        return () -> new NotFoundException("No chore type found with id " + id);
    }
}
