package repositories.custom;

import models.custom.WeeklyChores;

import java.util.List;

public interface WeeklyChoresRepository {
    List<WeeklyChores> getAll();
}
