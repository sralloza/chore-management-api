package es.sralloza.choremanagementapi.utils;

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

    public long getCurrentMillis() {
        return System.currentTimeMillis();
    }
}
