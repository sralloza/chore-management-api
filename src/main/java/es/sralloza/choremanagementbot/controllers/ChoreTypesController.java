package es.sralloza.choremanagementbot.controllers;

import es.sralloza.choremanagementbot.models.db.DBChoreType;
import es.sralloza.choremanagementbot.repositories.db.DBChoreTypesRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static org.springframework.http.HttpStatus.NO_CONTENT;

@RestController
@RequestMapping("/chore-types")
public class ChoreTypesController {
    @Autowired
    private DBChoreTypesRepository dbChoreTypesRepository;

    @GetMapping()
    public List<DBChoreType> listChoreTypes() {
        return dbChoreTypesRepository.findAll();
    }

    @PostMapping()
    public DBChoreType createTenant(@RequestBody DBChoreType choreType) {
        return dbChoreTypesRepository.save(choreType);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = NO_CONTENT)
    public void deleteChoreType(@PathVariable("id") String id) {
        dbChoreTypesRepository.deleteById(id);
    }
}
