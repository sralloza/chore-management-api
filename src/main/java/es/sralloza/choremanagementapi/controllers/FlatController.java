package es.sralloza.choremanagementapi.controllers;

import es.sralloza.choremanagementapi.models.custom.Flat;
import es.sralloza.choremanagementapi.models.custom.FlatCreateCode;
import es.sralloza.choremanagementapi.models.io.FlatCreate;
import es.sralloza.choremanagementapi.security.SimpleSecurity;
import es.sralloza.choremanagementapi.services.FlatsService;
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
import java.util.List;

import static org.springframework.http.HttpStatus.NO_CONTENT;

@RestController
@RequestMapping("/api/v1/flats")
public class FlatController {
  @Autowired
  private FlatsService flatsService;
  @Autowired
  private SimpleSecurity security;

  @PostMapping("/create-code")
  public FlatCreateCode requestFlatCreateCode() {
    security.requireAdmin();
    return flatsService.requestFlatCreateCode();
  }

  @GetMapping("")
  public List<Flat> listFlats() {
    security.requireAdmin();
    return flatsService.listFlats();
  }

  @PostMapping("")
  public Flat createFlat(@RequestBody @Valid FlatCreate flatCreate) {
    return flatsService.createFlat(flatCreate);
  }

  @DeleteMapping("/{flat_name}")
  @ResponseStatus(value = NO_CONTENT)
  public void deleteFlat(@PathVariable("flat_name") String flatName) {
    security.requireAdmin();
    flatsService.deleteFlat(flatName);
  }
}
