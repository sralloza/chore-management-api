package es.sralloza.choremanagementbot.services;

import es.sralloza.choremanagementbot.exceptions.BadRequestException;
import es.sralloza.choremanagementbot.models.db.DBSkippedWeek;
import es.sralloza.choremanagementbot.repositories.db.DBSkippedWeekRepository;
import es.sralloza.choremanagementbot.utils.DateProvider;
import es.sralloza.choremanagementbot.utils.DateUtils;
import es.sralloza.choremanagementbot.validator.WeekIdValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.temporal.WeekFields;
import java.util.Locale;

@Service
public class SkipWeeksService {
    @Autowired
    private TenantsService tenantsService;
    @Autowired
    private DBSkippedWeekRepository repository;
    @Autowired
    private WeekIdValidator weekIdValidator;
    @Autowired
    private DateUtils dateUtils;
    @Autowired
    private DateProvider dateProvider;

    public void skipWeek(String weekId, Integer tenantId) {
        weekIdValidator.validateSyntax(weekId);
        validatePastWeekId(weekId);

        if (repository.findByWeekIdAndTenantId(weekId, tenantId).isPresent()) {
            String tenantName = tenantsService.getTenantById(tenantId).getUsername();
            throw new BadRequestException("Tenant " + tenantName + " has already skipped the week " + weekId);
        }

        var ignoredWeek = new DBSkippedWeek()
                .setWeekId(weekId)
                .setTenantId(tenantId);
        repository.save(ignoredWeek);
    }

    public void unSkipWeek(String weekId, Integer tenantId) {
        weekIdValidator.validateSyntax(weekId);
        var skippedWeek = repository.findByWeekIdAndTenantId(weekId, tenantId);

        if (skippedWeek.isEmpty()) {
            String tenantName = tenantsService.getTenantById(tenantId).getUsername();
            throw new BadRequestException("Tenant " + tenantName + " has not skipped the week " + weekId);
        }

        repository.delete(skippedWeek.get());
    }

    private void validatePastWeekId(String weekId) {
        if (weekId.equals(dateUtils.getCurrentWeekId())) {
            throw new BadRequestException("Cannot skip the current week");
        }
        var weekDate = dateUtils.getLocalDateByWeekId(weekId);
        WeekFields weekFields = WeekFields.of(Locale.getDefault());
        var currentDate = dateProvider.getCurrentDate()
                .with(weekFields.dayOfWeek(), 1);

        if (weekDate.isBefore(currentDate)) {
            throw new BadRequestException("Cannot skip a week in the past");
        }
    }
}
