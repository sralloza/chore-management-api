package repositories.custom;

import builders.ChoreTypeTicketsMapper;
import models.custom.ChoreTypeTickets;
import models.db.DBChore;
import models.db.DBChoreType;
import models.db.DBTicket;
import repositories.db.DBChoreTypesRepository;
import repositories.db.DBTicketsRepository;

import java.util.List;
import java.util.stream.Collectors;

public class ChoreTypeTicketsRepositoryImp implements ChoreTypeTicketsRepository{
    private final DBChoreTypesRepository dbChoreTypesRepository;
    private final DBTicketsRepository dbTicketsRepository;
    private final ChoreTypeTicketsMapper mapper;

    public ChoreTypeTicketsRepositoryImp(DBChoreTypesRepository dbChoreTypesRepository,
                                         DBTicketsRepository dbTicketsRepository,
                                         ChoreTypeTicketsMapper mapper) {
        this.dbChoreTypesRepository = dbChoreTypesRepository;
        this.dbTicketsRepository = dbTicketsRepository;
        this.mapper = mapper;
    }

    @Override
    public List<ChoreTypeTickets> getAll() {
        List<DBTicket> tickets = dbTicketsRepository.getAll();
        List<DBChoreType> chores = dbChoreTypesRepository.getAll();
        return chores.stream()
                .map(dbChoreType -> mapper.build(dbChoreType, tickets))
                .collect(Collectors.toList());
    }
}
