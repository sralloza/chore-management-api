package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.builders.SimpleChoreMapper;
import es.sralloza.choremanagementapi.models.SimpleChore;
import es.sralloza.choremanagementapi.repositories.db.DBChoresRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Nullable;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class SimpleChoresService {
    @Autowired
    private DBChoresRepository repository;
    @Autowired
    private SimpleChoreMapper mapper;

    public List<SimpleChore> listSimpleChores(@Nullable String choreType,
                                              @Nullable Long tenantId,
                                              @Nullable String weekId,
                                              @Nullable Boolean done) {
        return repository.findAll().stream()
            .map(mapper::build)
            .filter(chore -> choreType == null || chore.getChoreType().equals(choreType))
            .filter(chore -> tenantId == null || chore.getTenantId().equals(tenantId))
            .filter(chore -> weekId == null || chore.getWeekId().equals(weekId))
            .filter(chore -> done == null || chore.getDone().equals(done))
            .collect(Collectors.toList());
    }
}
