package repositories.custom;

import builders.ChoreMapper;
import models.custom.Chore;
import models.db.DBChore;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import repositories.db.DBChoresRepository;

import java.util.List;

import static org.mockito.Mockito.when;

public class ChoresRepositoryTest {
    private static final String TYPE_1 = "type1";
    private static final String TYPE_2 = "type2";
    private static final String TYPE_3 = "type3";
    private static final String WEEK_1 = "2022.01";
    private static final String WEEK_2 = "2022.02";
    private static final String WEEK_3 = "2022.03";

    @Mock
    private DBChoresRepository dbChoresRepository;

    private ChoresRepository choresRepository;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        choresRepository = new ChoresRepositoryImp(dbChoresRepository, new ChoreMapper());

        var dbChoreList = List.of(
                new DBChore(1L, TYPE_1, 1, WEEK_1, true),
                new DBChore(2L, TYPE_2, 2, WEEK_1, true),
                new DBChore(3L, TYPE_3, 3, WEEK_1, false),
                new DBChore(4L, TYPE_1, 1, WEEK_2, true),
                new DBChore(5L, TYPE_2, 2, WEEK_2, false),
                new DBChore(6L, TYPE_3, 1, WEEK_2, true),
                new DBChore(7L, TYPE_3, 2, WEEK_2, true),
                new DBChore(8L, TYPE_1, 1, WEEK_3, true),
                new DBChore(9L, TYPE_2, 2, WEEK_3, true),
                new DBChore(10L, TYPE_3, 1, WEEK_3, false),
                new DBChore(11L, TYPE_3, 2, WEEK_3, true)
        );
        when(dbChoresRepository.getAll()).thenReturn(dbChoreList);
    }

    @Test
    public void shouldGetChores() {
        // Given
        var expected = new Chore[]{
                new Chore(WEEK_1, TYPE_1, List.of(1), true),
                new Chore(WEEK_1, TYPE_2, List.of(2), true),
                new Chore(WEEK_1, TYPE_3, List.of(3), false),
                new Chore(WEEK_2, TYPE_1, List.of(1), true),
                new Chore(WEEK_2, TYPE_2, List.of(2), false),
                new Chore(WEEK_2, TYPE_3, List.of(1, 2), true),
                new Chore(WEEK_3, TYPE_1, List.of(1), true),
                new Chore(WEEK_3, TYPE_2, List.of(2), true),
                new Chore(WEEK_3, TYPE_3, List.of(1, 2), false)
        };

        // When
        var actual = choresRepository.getAll().toArray(new Chore[0]);

        // Then
        Assertions.assertArrayEquals(expected, actual);
    }
}
