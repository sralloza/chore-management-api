package es.sralloza.choremanagementapi.controllers;

import es.sralloza.choremanagementapi.models.custom.ChoreType;
import es.sralloza.choremanagementapi.security.SimpleSecurity;
import es.sralloza.choremanagementapi.services.ChoreTypesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;
import java.util.List;

import static org.springframework.http.HttpStatus.NO_CONTENT;

@RestController
@RequestMapping("/v1/chore-types")
public class ChoreTypesController {
    @Autowired
    private ChoreTypesService service;
    @Autowired
    private SimpleSecurity security;

    @GetMapping()
    public List<ChoreType> listChoreTypes() {
        security.requireUser();
        return service.listChoreTypes();
    }

    @GetMapping("/{id}")
    public ChoreType getChoreType(@PathVariable String id) {
        security.requireUser();
        return service.getChoreTypeById(id);
    }

    @PostMapping()
    public ChoreType createChoreType(@RequestBody @NotNull @Valid ChoreType choreType) {
        security.requireAdmin();
        return service.createChoreType(choreType);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(value = NO_CONTENT)
    public void deleteChoreType(@PathVariable("id") String id) {
        security.requireAdmin();
        service.deleteChoreType(id);
    }
}
