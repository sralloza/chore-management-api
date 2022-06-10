package es.sralloza.choremanagementbot.utils;

import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
public class DateProvider {
    public LocalDate getCurrentDate() {
        return LocalDate.now();
    }

    public LocalDateTime getCurrentDateTime() {
        return LocalDateTime.now();
    }
}
