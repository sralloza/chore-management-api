package utils;

import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.utils.ChoreUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SuppressWarnings("UnnecessaryLocalVariable")
public class ChoreUtilsTest {
    public static final String WEEK_1 = "2022.01";
    public static final String WEEK_2 = "2022.02";
    public static final String TYPE_1 = "type1";
    public static final String TYPE_2 = "type2";
    public static final String TYPE_3 = "type3";
    public static final String WEEK_3 = "2022.03";

    private ChoreUtils choreUtils;

    @BeforeEach
    public void setUp() {
        choreUtils = new ChoreUtils();
    }

    @Test
    public void shouldRepeatListSameItemsThanBefore() {
        // Given
        var originalList = List.of(1, 2, 3);
        var size = 3;
        var expected = originalList;

        // When
        var result = choreUtils.repeatArray(originalList, size);

        // Then
        assertEquals(expected, result);
    }

    @Test
    public void shouldRepeatListMoreItemsThanBefore() {
        // Given
        var originalList = List.of(1, 2, 3);
        var size = 5;
        var expected = List.of(1, 2, 3, 1, 2);

        // When
        var result = choreUtils.repeatArray(originalList, size);

        // Then
        assertEquals(expected, result);
    }

    @Test
    public void shouldRepeatListLessItemsThanBefore() {
        // Given
        var originalList = List.of(1, 2, 3, 4, 5);
        var size = 3;
        var expected = List.of(1, 2, 3);

        // When
        var result = choreUtils.repeatArray(originalList, size);

        // Then
        assertEquals(expected, result);
    }

//    @Test
    public void shouldRotateChoreListHappyPath() {
        // Given
        var originalChoreList = List.of(
                new Chore(WEEK_1, TYPE_1, List.of(1), true),
                new Chore(WEEK_1, TYPE_2, List.of(2), false),
                new Chore(WEEK_1, TYPE_3, List.of(3), true)
        );
        var expected = List.of(
                new Chore(WEEK_2, TYPE_1, List.of(2), false),
                new Chore(WEEK_2, TYPE_2, List.of(3), false),
                new Chore(WEEK_2, TYPE_3, List.of(1), false)
        );

        // When
//        var actual = choreUtils.rotate(originalChoreList, WEEK_2);
        var actual = originalChoreList;

        // Then
        assertEquals(expected, actual);
    }

//    @Test
    public void shouldRotateChoreListRotateTwice() {
        // Given
        var originalChoreList = List.of(
                new Chore(WEEK_1, TYPE_1, List.of(1), true),
                new Chore(WEEK_1, TYPE_2, List.of(2), false),
                new Chore(WEEK_1, TYPE_3, List.of(3), true)
        );
        var expected = List.of(
                new Chore(WEEK_3, TYPE_1, List.of(3), false),
                new Chore(WEEK_3, TYPE_2, List.of(1), false),
                new Chore(WEEK_3, TYPE_3, List.of(2), false)
        );

        // When
//        var middle = choreUtils.rotate(originalChoreList, WEEK_2);
//        var actual = choreUtils.rotate(middle, WEEK_3);
        var actual = originalChoreList;

        // Then
        assertEquals(expected, actual);
    }
}
