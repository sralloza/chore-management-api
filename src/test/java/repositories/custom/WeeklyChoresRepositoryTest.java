package repositories.custom;

import es.sralloza.choremanagementbot.builders.ChoreMapper;
import es.sralloza.choremanagementbot.builders.WeeklyChoresMapper;
import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.models.db.DBRotation;
import es.sralloza.choremanagementbot.repositories.custom.ChoresRepository;
import es.sralloza.choremanagementbot.repositories.custom.WeeklyChoresRepository;
import es.sralloza.choremanagementbot.repositories.db.DBChoresRepository;
import es.sralloza.choremanagementbot.repositories.db.DBRotationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.mockito.Mockito.when;

public class WeeklyChoresRepositoryTest extends CustomRepositoryTestBase {
    @Mock
    private DBChoresRepository dbChoresRepository;
    @Mock
    private ChoresRepository choresRepository;
    @Mock
    private DBRotationRepository dbRotationRepository;

    private WeeklyChoresRepository weeklyChoresRepository;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        weeklyChoresRepository = new WeeklyChoresRepository(choresRepository,
                dbChoresRepository, dbRotationRepository, new ChoreMapper(), new WeeklyChoresMapper());

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

        List<DBRotation> rotationList = List.of(
                new DBRotation(1L, WEEK_1, 0),
                new DBRotation(2L, WEEK_2, 1),
                new DBRotation(3L, WEEK_3, 2)
        );
        when(dbRotationRepository.findAll()).thenReturn(rotationList);
    }

    @Test
    public void shouldGetWeeklyChores() {
        // Given
        var expected = new WeeklyChores[]{
                new WeeklyChores(WEEK_1, List.of(
                        buildChore(WEEK_1, TYPE_1, List.of(1), true),
                        buildChore(WEEK_1, TYPE_2, List.of(2), true),
                        buildChore(WEEK_1, TYPE_3, List.of(3), false)
                ), 0),
                new WeeklyChores(WEEK_2, List.of(
                        buildChore(WEEK_2, TYPE_1, List.of(1), true),
                        buildChore(WEEK_2, TYPE_2, List.of(2), false),
                        buildChore(WEEK_2, TYPE_3, List.of(1, 2), true)
                ), 1),
                new WeeklyChores(WEEK_3, List.of(
                        buildChore(WEEK_3, TYPE_1, List.of(1), true),
                        buildChore(WEEK_3, TYPE_2, List.of(2), true),
                        buildChore(WEEK_3, TYPE_3, List.of(1, 2), false)
                ), 2)
        };

        // When
        var actual = weeklyChoresRepository.findAll().toArray(new WeeklyChores[0]);

        // Then
        assertArrayEquals(expected, actual);
    }
}
