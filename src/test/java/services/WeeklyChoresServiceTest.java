package services;

import es.sralloza.choremanagementbot.exceptions.NotImplementedException;
import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.Flatmate;
import es.sralloza.choremanagementbot.models.custom.WeeklyChores;
import es.sralloza.choremanagementbot.models.db.DBChoreType;
import es.sralloza.choremanagementbot.repositories.custom.FlatmatesRepository;
import es.sralloza.choremanagementbot.repositories.custom.WeeklyChoresRepository;
import es.sralloza.choremanagementbot.repositories.db.DBChoreTypesRepository;
import es.sralloza.choremanagementbot.services.WeeklyChoresService;
import es.sralloza.choremanagementbot.utils.ChoreUtils;
import es.sralloza.choremanagementbot.utils.DateUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.function.Executable;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

public class WeeklyChoresServiceTest {
    public static final String WEEK_3 = "2022.05";
    public static final String WEEK_1 = "2021.52";
    public static final String WEEK_2 = "2022.04";
    public static final String TYPE_1 = "type1";
    public static final String TYPE_2 = "type2";
    public static final String TYPE_3 = "type3";

    @Mock
    private WeeklyChoresRepository repository;

    @Mock
    private DBChoreTypesRepository choreTypesRepository;

    @Mock
    private FlatmatesRepository flatmatesRepository;

    @Mock
    private DateUtils dateUtils;

    private WeeklyChoresService service;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        service = new WeeklyChoresService(repository, choreTypesRepository, flatmatesRepository, dateUtils, new ChoreUtils());
    }

    @Test
    public void shouldCreateWeeklyChoresWhenDatabaseNotEmpty() {
        // Given
        var weeklyChores = List.of(
                new WeeklyChores(WEEK_1, List.of(
                        new Chore(WEEK_1, TYPE_1, List.of(1), List.of(1), true),
                        new Chore(WEEK_1, TYPE_2, List.of(2), List.of(2), true),
                        new Chore(WEEK_1, TYPE_3, List.of(3), List.of(3), true)
                )),
                new WeeklyChores(WEEK_2, List.of(
                        new Chore(WEEK_2, TYPE_1, List.of(1, 3), List.of(2), false),
                        new Chore(WEEK_2, TYPE_2, List.of(3), List.of(3), false),
                        new Chore(WEEK_2, TYPE_3, List.of(1), List.of(1), false)
                ))
        );
        var expected = new WeeklyChores(WEEK_3, List.of(
                new Chore(WEEK_3, TYPE_1, List.of(3), List.of(3), false),
                new Chore(WEEK_3, TYPE_2, List.of(1), List.of(1), false),
                new Chore(WEEK_3, TYPE_3, List.of(2), List.of(2), false)
        ));
        when(repository.getAll()).thenReturn(weeklyChores);
        when(dateUtils.getCurentWeekId()).thenReturn(WEEK_3);

        // When
        var actual = service.createWeeklyChores();

        // Then
        assertEquals(expected, actual);
    }

    @Test
    public void shouldCreateWeeklyChoresWhenDatabaseEmptyAndSameFlatmatesAsChores() {
        // Given
        var expected = new WeeklyChores(WEEK_3, List.of(
                new Chore(WEEK_3, TYPE_1, List.of(1), List.of(1), false),
                new Chore(WEEK_3, TYPE_2, List.of(2), List.of(2), false),
                new Chore(WEEK_3, TYPE_3, List.of(3), List.of(3), false)
        ));
        when(repository.getAll()).thenReturn(Collections.emptyList());
        var flatmates = List.of(
                new Flatmate(1, "user1", null, null),
                new Flatmate(2, "user2", null, null),
                new Flatmate(3, "user3", null, null)
        );
        when(flatmatesRepository.getAll()).thenReturn(flatmates);
        var choreTypes = List.of(
                new DBChoreType("type1", null),
                new DBChoreType("type2", null),
                new DBChoreType("type3", null)
        );
        when(choreTypesRepository.findAll()).thenReturn(choreTypes);
        when(dateUtils.getCurentWeekId()).thenReturn(WEEK_3);

        // When
        var actual = service.createWeeklyChores();

        // Then
        assertEquals(expected, actual);
    }

    @Test
    public void shouldReturnErrorWhenDatabaseEmptyAndDifferentNumberOfFlatmatesAndChores() {
        // Given
        when(repository.getAll()).thenReturn(Collections.emptyList());
        var flatmates = List.of(
                new Flatmate(1, "user1", null, null),
                new Flatmate(2, "user2", null, null)
        );
        when(flatmatesRepository.getAll()).thenReturn(flatmates);
        var choreTypes = List.of(
                new DBChoreType("type1", null),
                new DBChoreType("type2", null),
                new DBChoreType("type3", null)
        );
        when(choreTypesRepository.findAll()).thenReturn(choreTypes);

        // When
        Executable action = () -> service.createWeeklyChores();

        // Then
        NotImplementedException exception = assertThrows(NotImplementedException.class, action);
        assertEquals("Can't create tasks: different number of Flatmates and Tasks defined", exception.getMessage());
    }
}
