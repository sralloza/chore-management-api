package repositories.custom;

import builders.FlatmateMapper;
import models.custom.Chore;
import models.custom.Flatmate;
import models.db.DBFlatmate;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import repositories.db.DBFlatmatesRepository;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.mockito.Mockito.when;

public class FlatmatesRepositoryTest {
    private static final String TYPE_1 = "type1";
    private static final String TYPE_2 = "type2";
    private static final String TYPE_3 = "type3";
    private static final String WEEK_1 = "2022.01";
    private static final String WEEK_2 = "2022.02";
    private static final String WEEK_3 = "2022.03";
    private static final UUID UUID_1 = UUID.fromString("416b19b7-bb29-41fa-9902-b286223c8470");
    private static final UUID UUID_2 = UUID.fromString("5148b184-c9eb-4079-b2f1-b88f86794010");
    private static final UUID UUID_3 = UUID.fromString("a513e811-90a5-40d4-a6ec-f78feeef36b1");

    @Mock
    private ChoresRepository choresRepository;

    @Mock
    private DBFlatmatesRepository dbFlatmatesRepository;

    private FlatmatesRepository flatmatesRepository;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        flatmatesRepository = new FlatmatesRepositoryImp(choresRepository, dbFlatmatesRepository, new FlatmateMapper());

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

        List<DBFlatmate> flatmateList = List.of(
                new DBFlatmate(1, "user1", UUID_1),
                new DBFlatmate(2, "user2", UUID_2),
                new DBFlatmate(3, "user3", UUID_3)
        );
        when(dbFlatmatesRepository.getAll()).thenReturn(flatmateList);
    }

    @Test
    public void shouldGetFlatmates() {
        // Given
        var expected = new Flatmate[]{
                new Flatmate(1, "user1", UUID_1, List.of(new Chore(WEEK_3, TYPE_3, List.of(1, 2), false))),
                new Flatmate(2, "user2", UUID_2, List.of(
                        new Chore(WEEK_2, TYPE_2, List.of(2), false),
                        new Chore(WEEK_3, TYPE_3, List.of(1, 2), false))),
                new Flatmate(3, "user3", UUID_3, List.of(new Chore(WEEK_1, TYPE_3, List.of(3), false)))
        };

        // When
        var actual = flatmatesRepository.getAll().toArray(new Flatmate[0]);

        // Then
        assertArrayEquals(expected, actual);
    }
}
