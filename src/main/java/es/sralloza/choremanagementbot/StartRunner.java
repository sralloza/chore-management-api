package es.sralloza.choremanagementbot;

import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.models.db.DBChoreType;
import es.sralloza.choremanagementbot.models.db.DBFlatmate;
import es.sralloza.choremanagementbot.repositories.custom.WeeklyChoresRepository;
import es.sralloza.choremanagementbot.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementbot.repositories.db.DBFlatmatesRepository;
import es.sralloza.choremanagementbot.services.WeeklyChoresService;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@AllArgsConstructor
public class StartRunner implements ApplicationRunner {

    /* Add whatever Bean you need here and autowire them through the constructor or with @Autowired */
    @Autowired
    private WeeklyChoresService service;

    @Autowired
    private WeeklyChoresRepository repository;

    @Autowired
    private DBFlatmatesRepository dbFlatmatesRepository;

    @Autowired
    private DBChoreTypesRepository dbChoreTypesRepository;

    @Override
    public void run(ApplicationArguments args) {
        List<DBFlatmate> flatmates = List.of(
                new DBFlatmate(1111, "user1", UUID.randomUUID()),
                new DBFlatmate(2222, "user2", UUID.randomUUID())
        );
        dbFlatmatesRepository.saveAll(flatmates);

        List<DBChoreType> dbChoreTypeList = List.of(
                new DBChoreType("type1", "description1"),
                new DBChoreType("type2", "description2")
        );
        dbChoreTypesRepository.saveAll(dbChoreTypeList);

        List<WeeklyChores> weeklyChoresList = repository.findAll();
        System.out.println("Initial weekly chores:");
        System.out.println(weeklyChoresList);
        service.createWeeklyChores();

        System.out.println("Final weekly chores:");
        List<WeeklyChores> weeklyChoresList1 = repository.findAll();
        System.out.println(weeklyChoresList1);
    }
}
