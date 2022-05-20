package utils;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class DateProviderTest {
    private DateProvider dateProvider;

    @BeforeEach
    public void setUp() {
        dateProvider = new DateProvider();
    }

    @Test
    public void shouldGetTodaysDate() {
        // Given
        var expected = LocalDate.now();

        // When
        var actual = dateProvider.getCurrentDate();

        assertEquals(expected, actual);
    }
}
