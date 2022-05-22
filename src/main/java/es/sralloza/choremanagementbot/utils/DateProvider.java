package es.sralloza.choremanagementbot.utils;

import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class DateProvider {
    public LocalDate getCurrentDate() {
        return LocalDate.now();
    }
}
