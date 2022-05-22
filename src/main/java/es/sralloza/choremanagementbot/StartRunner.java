package es.sralloza.choremanagementbot;

import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.repositories.custom.WeeklyChoresRepository;
import es.sralloza.choremanagementbot.services.WeeklyChoresService;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@AllArgsConstructor
public class StartRunner implements ApplicationRunner {

    /* Add whatever Bean you need here and autowire them through the constructor or with @Autowired */
    @Autowired
    private WeeklyChoresService service;

    @Autowired
    private WeeklyChoresRepository repository;


    @Override
    public void run(ApplicationArguments args) throws Exception {
        List<WeeklyChores> weeklyChoresList = repository.getAll();
        System.out.println("Initial weekly chores:");
        System.out.println(weeklyChoresList);
        service.createWeeklyChores();

        System.out.println("Final weekly chores:");
        List<WeeklyChores> weeklyChoresList1 = repository.getAll();
        System.out.println(weeklyChoresList1);
        // Do whatever you need here inside
    }
}
