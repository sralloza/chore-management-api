package repositories.custom;

import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.repositories.custom.ChoresRepository;
import es.sralloza.choremanagementbot.repositories.custom.WeeklyChoresRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.mockito.Mockito.when;

public class WeeklyChoresRepositoryTest extends CustomRepositoryTestBase {
    @Mock
    private ChoresRepository choresRepository;

    private WeeklyChoresRepository weeklyChoresRepository;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        weeklyChoresRepository = new WeeklyChoresRepository(choresRepository);

        List<Chore> choreList = List.of(
                buildChore(WEEK_1, TYPE_1, List.of(1), true),
                buildChore(WEEK_1, TYPE_2, List.of(2), true),
                buildChore(WEEK_1, TYPE_3, List.of(3), false),
                buildChore(WEEK_2, TYPE_1, List.of(1), true),
                buildChore(WEEK_2, TYPE_2, List.of(2), false),
                buildChore(WEEK_2, TYPE_3, List.of(1, 2), true),
                buildChore(WEEK_3, TYPE_1, List.of(1), true),
                buildChore(WEEK_3, TYPE_2, List.of(2), true),
                buildChore(WEEK_3, TYPE_3, List.of(1, 2), false)
        );
        when(choresRepository.getAll()).thenReturn(choreList);
    }

    @Test
    public void shouldGetWeeklyChores() {
        // Given
        var expected = new WeeklyChores[]{
                new WeeklyChores(WEEK_1, List.of(
                        buildChore(WEEK_1, TYPE_1, List.of(1), true),
                        buildChore(WEEK_1, TYPE_2, List.of(2), true),
                        buildChore(WEEK_1, TYPE_3, List.of(3), false)
                )),
                new WeeklyChores(WEEK_2, List.of(
                        buildChore(WEEK_2, TYPE_1, List.of(1), true),
                        buildChore(WEEK_2, TYPE_2, List.of(2), false),
                        buildChore(WEEK_2, TYPE_3, List.of(1, 2), true)
                )),
                new WeeklyChores(WEEK_3, List.of(
                        buildChore(WEEK_3, TYPE_1, List.of(1), true),
                        buildChore(WEEK_3, TYPE_2, List.of(2), true),
                        buildChore(WEEK_3, TYPE_3, List.of(1, 2), false)
                ))
        };

        // When
        var actual = weeklyChoresRepository.getAll().toArray(new WeeklyChores[0]);

        // Then
        assertArrayEquals(expected, actual);
    }
}
