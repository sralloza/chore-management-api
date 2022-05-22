package repositories.custom;

import es.sralloza.choremanagementbot.builders.FlatmateMapper;
import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.Flatmate;
import es.sralloza.choremanagementbot.models.db.DBFlatmate;
import es.sralloza.choremanagementbot.repositories.custom.ChoresRepository;
import es.sralloza.choremanagementbot.repositories.custom.FlatmatesRepository;
import es.sralloza.choremanagementbot.repositories.db.DBFlatmatesRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.mockito.Mockito.when;

public class FlatmatesRepositoryTest extends CustomRepositoryTestBase {
    @Mock
    private ChoresRepository choresRepository;

    @Mock
    private DBFlatmatesRepository dbFlatmatesRepository;

    private FlatmatesRepository flatmatesRepository;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        flatmatesRepository = new FlatmatesRepository(choresRepository, dbFlatmatesRepository, new FlatmateMapper());

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

        List<DBFlatmate> flatmateList = List.of(
                new DBFlatmate(1, USERNAME_1, UUID_1),
                new DBFlatmate(2, USERNAME_2, UUID_2),
                new DBFlatmate(3, USERNAME_3, UUID_3)
        );
        when(dbFlatmatesRepository.findAll()).thenReturn(flatmateList);
    }

    @Test
    public void shouldGetFlatmates() {
        // Given
        var expected = new Flatmate[]{
                new Flatmate(1, USERNAME_1, UUID_1, List.of(
                        buildChore(WEEK_3, TYPE_3, List.of(1, 2), false))),
                new Flatmate(2, USERNAME_2, UUID_2, List.of(
                        buildChore(WEEK_2, TYPE_2, List.of(2), false),
                        buildChore(WEEK_3, TYPE_3, List.of(1, 2), false))),
                new Flatmate(3, USERNAME_3, UUID_3, List.of(
                        buildChore(WEEK_1, TYPE_3, List.of(3), false)))
        };

        // When
        var actual = flatmatesRepository.getAll().toArray(new Flatmate[0]);

        // Then
        assertArrayEquals(expected, actual);
    }
}
