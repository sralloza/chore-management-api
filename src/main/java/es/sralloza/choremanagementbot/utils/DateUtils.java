package es.sralloza.choremanagementbot.utils;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;

import javax.inject.Inject;
import java.time.LocalDate;
import java.time.temporal.WeekFields;
import java.util.Locale;

@Service
public class DateUtils {
    @Autowired
    private final DateProvider dateProvider;

    public DateUtils(DateProvider dateProvider) {
        this.dateProvider = dateProvider;
    }

    private int getWeekNumberByDate(LocalDate localDate) {
        Locale locale = new Locale("es", "ES");
        return localDate.get(WeekFields.of(locale).weekOfYear());
    }

    private int getWeekDayNumberByDate(LocalDate localDate) {
        Locale locale = new Locale("es", "ES");
        return localDate.get(WeekFields.of(locale).dayOfWeek());
    }

    public String getCurentWeekId() {
        LocalDate localDate = dateProvider.getCurrentDate();
        int weekNumber = getWeekNumberByDate(localDate);
        int year = localDate.getYear();

        int newYearsEveWeekdayNumber = getWeekDayNumberByDate(LocalDate.of(year, 12, 31));

        if (newYearsEveWeekdayNumber <= 3 && weekNumber > 52) {
            weekNumber = 1;
            year += 1;
        }
        if (weekNumber == 0) {
            weekNumber = getWeekNumberByDate(localDate.minusDays(7)) + 1;
            year -= 1;
        }

        return String.format("%d.%02d", year, weekNumber);
    }
}
