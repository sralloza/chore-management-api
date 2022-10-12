package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.models.db.DBSkippedWeek;
import es.sralloza.choremanagementapi.repositories.db.DBSkippedWeekRepository;
import es.sralloza.choremanagementapi.utils.DateProvider;
import es.sralloza.choremanagementapi.utils.DateUtils;
import es.sralloza.choremanagementapi.validator.WeekIdValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.temporal.WeekFields;
import java.util.Locale;
import java.util.stream.Collectors;

@Service
public class SkipWeeksService {
    @Autowired
    private DBSkippedWeekRepository repository;
    @Autowired
    private WeekIdValidator weekIdValidator;
    @Autowired
    private DateUtils dateUtils;
    @Autowired
    private DateProvider dateProvider;

    public void skipWeek(String weekId, Long userId) {
        weekIdValidator.validateSyntax(weekId);
        validatePastWeekId(weekId, "skip");

        if (repository.findByWeekIdAndUserId(weekId, userId).isPresent()) {
            throw new BadRequestException("User with id " + userId + " has already skipped the week " + weekId);
        }

        var ignoredWeek = new DBSkippedWeek()
            .setWeekId(weekId)
            .setUserId(userId);
        repository.save(ignoredWeek);
    }

    public void unSkipWeek(String weekId, Long userId) {
        weekIdValidator.validateSyntax(weekId);
        var skippedWeek = repository.findByWeekIdAndUserId(weekId, userId);
        validatePastWeekId(weekId, "unskip");

        if (skippedWeek.isEmpty()) {
            throw new BadRequestException("User with id " + userId + " has not skipped the week " + weekId);
        }

        repository.delete(skippedWeek.get());
    }

    private void validatePastWeekId(String weekId, String action) {
        if (weekId.equals(dateUtils.getCurrentWeekId())) {
            throw new BadRequestException("Cannot " + action + " the current week");
        }
        var weekDate = dateUtils.getLocalDateByWeekId(weekId);
        WeekFields weekFields = WeekFields.of(Locale.getDefault());
        var currentDate = dateProvider.getCurrentDate()
            .with(weekFields.dayOfWeek(), 1);

        if (weekDate.isBefore(currentDate)) {
            throw new BadRequestException("Cannot " + action + " a week in the past");
        }
    }

    public void deleteSkipWeeksByUserId(Long userId) {
        var skippedWeeks = repository.findAll().stream()
            .filter(week -> week.getUserId().equals(userId))
            .collect(Collectors.toList());
        repository.deleteAll(skippedWeeks);
    }
}
