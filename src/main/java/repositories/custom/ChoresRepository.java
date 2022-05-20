package repositories.custom;

import models.custom.Chore;

import java.util.List;

public interface ChoresRepository {
    List<Chore> getAll();
}
