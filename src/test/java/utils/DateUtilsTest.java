package utils;

import es.sralloza.choremanagementbot.utils.DateProvider;
import es.sralloza.choremanagementbot.utils.DateUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

public class DateUtilsTest {
    @Mock
    private DateProvider dateProvider;

    private DateUtils dateUtils;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        dateUtils = new DateUtils(dateProvider);
    }

    public static Object[] weekNumberTestData() {
        return new Object[][]{
                {"2017.51", LocalDate.of(2017, 12, 24)},
                {"2017.52", LocalDate.of(2017, 12, 25)},
                {"2017.52", LocalDate.of(2017, 12, 31)},
                {"2018.01", LocalDate.of(2018, 1, 1)},
                {"2018.51", LocalDate.of(2018, 12, 23)},
                {"2018.52", LocalDate.of(2018, 12, 24)},
                {"2018.52", LocalDate.of(2018, 12, 30)},
                {"2019.01", LocalDate.of(2018, 12, 31)},
                {"2019.01", LocalDate.of(2019, 1, 1)},
                {"2019.52", LocalDate.of(2019, 12, 29)},
                {"2020.01", LocalDate.of(2019, 12, 30)},
                {"2020.01", LocalDate.of(2019, 12, 31)},
                {"2020.01", LocalDate.of(2020, 1, 1)},
                {"2020.01", LocalDate.of(2020, 1, 5)},
                {"2020.02", LocalDate.of(2020, 1, 6)},
                {"2020.03", LocalDate.of(2020, 1, 19)},
                {"2020.33", LocalDate.of(2020, 8, 15)},
                {"2020.52", LocalDate.of(2020, 12, 26)},
                {"2020.52", LocalDate.of(2020, 12, 27)},
                {"2020.53", LocalDate.of(2020, 12, 28)},
                {"2020.53", LocalDate.of(2020, 12, 30)},
                {"2020.53", LocalDate.of(2020, 12, 31)},
                {"2020.53", LocalDate.of(2021, 1, 1)},
                {"2020.53", LocalDate.of(2021, 1, 3)},
                {"2021.01", LocalDate.of(2021, 1, 4)},
                {"2021.01", LocalDate.of(2021, 1, 6)},
                {"2021.04", LocalDate.of(2021, 1, 28)},
                {"2021.19", LocalDate.of(2021, 5, 12)},
                {"2021.32", LocalDate.of(2021, 8, 15)},
                {"2021.51", LocalDate.of(2021, 12, 24)},
                {"2021.51", LocalDate.of(2021, 12, 26)},
                {"2021.52", LocalDate.of(2021, 12, 27)},
                {"2021.52", LocalDate.of(2021, 12, 29)},
                {"2021.52", LocalDate.of(2021, 12, 31)},
                {"2021.52", LocalDate.of(2022, 1, 1)},
                {"2021.52", LocalDate.of(2022, 1, 2)},
                {"2022.01", LocalDate.of(2022, 1, 4)},
                {"2022.01", LocalDate.of(2022, 1, 7)},
                {"2022.04", LocalDate.of(2022, 1, 28)},
                {"2022.19", LocalDate.of(2022, 5, 11)},
                {"2022.33", LocalDate.of(2022, 8, 15)},
                {"2022.45", LocalDate.of(2022, 11, 7)},
                {"2022.50", LocalDate.of(2022, 12, 13)},
                {"2022.51", LocalDate.of(2022, 12, 23)},
                {"2022.51", LocalDate.of(2022, 12, 25)},
                {"2022.52", LocalDate.of(2022, 12, 26)},
                {"2022.52", LocalDate.of(2022, 12, 29)},
                {"2022.52", LocalDate.of(2022, 12, 30)},
                {"2022.52", LocalDate.of(2022, 12, 31)},
                {"2022.52", LocalDate.of(2023, 1, 1)},
                {"2023.01", LocalDate.of(2023, 1, 2)},
                {"2023.51", LocalDate.of(2023, 12, 24)},
                {"2023.52", LocalDate.of(2023, 12, 25)},
                {"2023.52", LocalDate.of(2023, 12, 31)},
                {"2024.01", LocalDate.of(2024, 1, 1)},
                {"2024.52", LocalDate.of(2024, 12, 29)},
                {"2025.01", LocalDate.of(2024, 12, 30)},
                {"2025.01", LocalDate.of(2024, 12, 31)},
                {"2025.01", LocalDate.of(2025, 1, 1)},
        };
    }

    @ParameterizedTest
    @MethodSource("weekNumberTestData")
    public void shouldGetWeekNumber(String expected, LocalDate date) {
        // Given
        when(dateProvider.getCurrentDate()).thenReturn(date);

        // When
        var actual = dateUtils.getCurentWeekId();

        // Then
        assertEquals(expected, actual);
    }
}
