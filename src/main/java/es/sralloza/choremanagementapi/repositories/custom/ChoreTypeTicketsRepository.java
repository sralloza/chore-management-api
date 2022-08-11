package es.sralloza.choremanagementapi.repositories.custom;

import es.sralloza.choremanagementapi.builders.ChoreTypeTicketsMapper;
import es.sralloza.choremanagementapi.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementapi.models.db.DBChoreType;
import es.sralloza.choremanagementapi.models.db.DBTicket;
import es.sralloza.choremanagementapi.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementapi.repositories.db.DBTicketsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.stream.Collectors;

@Repository
public class ChoreTypeTicketsRepository {
    @Autowired
    private DBChoreTypesRepository dbChoreTypesRepository;
    @Autowired
    private DBTicketsRepository dbTicketsRepository;
    @Autowired
    private ChoreTypeTicketsMapper mapper;

//    public ChoreTypeTicketsRepository(DBChoreTypesRepository dbChoreTypesRepository,
//                                      DBTicketsRepository dbTicketsRepository,
//                                      ChoreTypeTicketsMapper mapper) {
//        this.dbChoreTypesRepository = dbChoreTypesRepository;
//        this.dbTicketsRepository = dbTicketsRepository;
//        this.mapper = mapper;
//    }

    public List<ChoreTypeTickets> getAll() {
        List<DBTicket> tickets = dbTicketsRepository.findAll();
        List<DBChoreType> chores = dbChoreTypesRepository.findAll();
        return chores.stream()
                .map(dbChoreType -> mapper.build(dbChoreType, tickets))
                .collect(Collectors.toList());
    }
}
