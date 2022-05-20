package repositories.custom;

import models.custom.Chore;
import models.custom.WeeklyChores;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.mockito.Mockito.when;

public class WeeklyChoresRepositoryTest {
    private static final String TYPE_1 = "type1";
    private static final String TYPE_2 = "type2";
    private static final String TYPE_3 = "type3";
    private static final String WEEK_1 = "2022.01";
    private static final String WEEK_2 = "2022.02";
    private static final String WEEK_3 = "2022.03";

    @Mock
    private ChoresRepository choresRepository;

    private WeeklyChoresRepository weeklyChoresRepository;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        weeklyChoresRepository = new WeeklyChoresRepositoryImp(choresRepository);

        List<Chore> choreList = List.of(
                new Chore(WEEK_1, TYPE_1, List.of(1), true),
                new Chore(WEEK_1, TYPE_2, List.of(2), true),
                new Chore(WEEK_1, TYPE_3, List.of(3), false),
                new Chore(WEEK_2, TYPE_1, List.of(1), true),
                new Chore(WEEK_2, TYPE_2, List.of(2), false),
                new Chore(WEEK_2, TYPE_3, List.of(1, 2), true),
                new Chore(WEEK_3, TYPE_1, List.of(1), true),
                new Chore(WEEK_3, TYPE_2, List.of(2), true),
                new Chore(WEEK_3, TYPE_3, List.of(1, 2), false)
        );
        when(choresRepository.getAll()).thenReturn(choreList);
    }

    @Test
    public void shouldGetWeeklyChores() {
        // Given
        var expected = new WeeklyChores[]{
                new WeeklyChores(WEEK_1, List.of(
                        new Chore(WEEK_1, TYPE_1, List.of(1), true),
                        new Chore(WEEK_1, TYPE_2, List.of(2), true),
                        new Chore(WEEK_1, TYPE_3, List.of(3), false)
                )),
                new WeeklyChores(WEEK_2, List.of(
                        new Chore(WEEK_2, TYPE_1, List.of(1), true),
                        new Chore(WEEK_2, TYPE_2, List.of(2), false),
                        new Chore(WEEK_2, TYPE_3, List.of(1, 2), true)
                )),
                new WeeklyChores(WEEK_3, List.of(
                        new Chore(WEEK_3, TYPE_1, List.of(1), true),
                        new Chore(WEEK_3, TYPE_2, List.of(2), true),
                        new Chore(WEEK_3, TYPE_3, List.of(1, 2), false)
                ))
        };

        // When
        var actual = weeklyChoresRepository.getAll().toArray(new WeeklyChores[0]);

        // Then
        assertArrayEquals(expected, actual);
    }
}
