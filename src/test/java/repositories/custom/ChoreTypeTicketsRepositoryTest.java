package repositories.custom;

import es.sralloza.choremanagementbot.builders.ChoreTypeTicketsMapper;
import es.sralloza.choremanagementbot.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementbot.models.db.DBChoreType;
import es.sralloza.choremanagementbot.models.db.DBTicket;
import es.sralloza.choremanagementbot.repositories.custom.ChoreTypeTicketsRepository;
import es.sralloza.choremanagementbot.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementbot.repositories.db.DBTicketsRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.mockito.Mockito.when;

public class ChoreTypeTicketsRepositoryTest {
    private static final String TYPE_1 = "type1";
    private static final String TYPE_2 = "type2";
    private static final String TYPE_3 = "type3";
    private static final String TYPE_1_DESCRIPTION = "type1 description";
    private static final String TYPE_2_DESCRIPTION = "type2 description";
    private static final String TYPE_3_DESCRIPTION = "type3 description";
    private static final String USER_1 = "user1";
    private static final String USER_2 = "user2";

    @Mock
    private DBChoreTypesRepository dbChoreTypesRepository;

    @Mock
    private DBTicketsRepository dbTicketsRepository;

    private ChoreTypeTicketsRepository repository;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        repository = new ChoreTypeTicketsRepository();

        List<DBChoreType> dbChoreList = List.of(
                new DBChoreType(TYPE_1, TYPE_1_DESCRIPTION),
                new DBChoreType(TYPE_2, TYPE_2_DESCRIPTION),
                new DBChoreType(TYPE_3, TYPE_3_DESCRIPTION)
        );
        when(dbChoreTypesRepository.findAll()).thenReturn(dbChoreList);

        List<DBTicket> dbTicketList = List.of(
                new DBTicket(1L, TYPE_1, USER_1, 0),
                new DBTicket(2L, TYPE_1, USER_2, 0),
                new DBTicket(3L, TYPE_2, USER_1, 1),
                new DBTicket(4L, TYPE_2, USER_2, -1)
        );
        when(dbTicketsRepository.findAll()).thenReturn(dbTicketList);
    }

    @Test
    public void shouldGetChoreTypeTickets() {
        // Given
        var expected = new ChoreTypeTickets[]{
                new ChoreTypeTickets(TYPE_1, TYPE_1_DESCRIPTION, Map.of(USER_1, 0, USER_2, 0)),
                new ChoreTypeTickets(TYPE_2, TYPE_2_DESCRIPTION, Map.of(USER_1, 1, USER_2, -1)),
                new ChoreTypeTickets(TYPE_3, TYPE_3_DESCRIPTION, Map.of())
        };

        // When
        var actual = repository.getAll().toArray(new ChoreTypeTickets[0]);

        // Then
        assertArrayEquals(expected, actual);
    }
}
