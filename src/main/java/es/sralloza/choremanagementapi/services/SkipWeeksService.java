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

    public void skipWeek(String weekId, Long tenantId) {
        weekIdValidator.validateSyntax(weekId);
        validatePastWeekId(weekId, "skip");

        if (repository.findByWeekIdAndTenantId(weekId, tenantId).isPresent()) {
            throw new BadRequestException("Tenant with id " + tenantId + " has already skipped the week " + weekId);
        }

        var ignoredWeek = new DBSkippedWeek()
            .setWeekId(weekId)
            .setTenantId(tenantId);
        repository.save(ignoredWeek);
    }

    public void unSkipWeek(String weekId, Long tenantId) {
        weekIdValidator.validateSyntax(weekId);
        var skippedWeek = repository.findByWeekIdAndTenantId(weekId, tenantId);
        validatePastWeekId(weekId, "unskip");

        if (skippedWeek.isEmpty()) {
            throw new BadRequestException("Tenant with id " + tenantId + " has not skipped the week " + weekId);
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

    public void deleteSkipWeeksByTenantId(Long tenantId) {
        var skippedWeeks = repository.findAll().stream()
            .filter(week -> week.getTenantId().equals(tenantId))
            .collect(Collectors.toList());
        repository.deleteAll(skippedWeeks);
    }
}
