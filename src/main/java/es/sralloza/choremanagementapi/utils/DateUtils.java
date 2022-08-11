package es.sralloza.choremanagementapi.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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

    public LocalDate getLocalDateByWeekId(String weekId) {
        int year = Integer.parseInt(weekId.split("\\.")[0]);
        int week = Integer.parseInt(weekId.split("\\.")[1]);

        WeekFields weekFields = WeekFields.of(Locale.getDefault());
        return LocalDate.now()
                .withYear(year)
                .with(weekFields.weekOfYear(), week)
                .with(weekFields.dayOfWeek(), 1);
    }

    private int getWeekNumberByDate(LocalDate localDate) {
        Locale locale = new Locale("es", "ES");
        return localDate.get(WeekFields.of(locale).weekOfYear());
    }

    private int getWeekDayNumberByDate(LocalDate localDate) {
        Locale locale = new Locale("es", "ES");
        return localDate.get(WeekFields.of(locale).dayOfWeek());
    }

    public String getWeekIdByDeltaDays(int days) {
        LocalDate localDate = dateProvider.getCurrentDate().plusDays(days);
        return getWeekIdByLocalDate(localDate);
    }

    public String getNextWeekId() {
        return getWeekIdByDeltaDays(7);
    }

    public String getLastWeekId() {
        return getWeekIdByDeltaDays(-7);
    }

    public String getCurrentWeekId() {
        LocalDate localDate = dateProvider.getCurrentDate();
        return getWeekIdByLocalDate(localDate);
    }

    private String getWeekIdByLocalDate(LocalDate localDate) {
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
