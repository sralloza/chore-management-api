package utils;

import models.custom.Chore;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

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
    public void shouldRotateChoreListHappyPath() {
        // Given
        var originalChoreList = List.of(
                new Chore(WEEK_1, TYPE_1, List.of(1), List.of(1), true),
                new Chore(WEEK_1, TYPE_2, List.of(2), List.of(2), false),
                new Chore(WEEK_1, TYPE_3, List.of(3), List.of(3), true)
        );
        var expected = List.of(
                new Chore(WEEK_2, TYPE_1, List.of(2), List.of(2), false),
                new Chore(WEEK_2, TYPE_2, List.of(3), List.of(3), false),
                new Chore(WEEK_2, TYPE_3, List.of(1), List.of(1), false)
        );

        // When
        var actual = choreUtils.rotate(originalChoreList, WEEK_2);

        // Then
        Assertions.assertEquals(expected, actual);
    }

    @Test
    public void shouldRotateChoreListRotateTwice() {
        // Given
        var originalChoreList = List.of(
                new Chore(WEEK_1, TYPE_1, List.of(1), List.of(1), true),
                new Chore(WEEK_1, TYPE_2, List.of(2), List.of(2), false),
                new Chore(WEEK_1, TYPE_3, List.of(3), List.of(3), true)
        );
        var expected = List.of(
                new Chore(WEEK_3, TYPE_1, List.of(3), List.of(3), false),
                new Chore(WEEK_3, TYPE_2, List.of(1), List.of(1), false),
                new Chore(WEEK_3, TYPE_3, List.of(2), List.of(2), false)
        );

        // When
        var middle = choreUtils.rotate(originalChoreList, WEEK_2);
        var actual = choreUtils.rotate(middle, WEEK_3);

        // Then
        Assertions.assertEquals(expected, actual);
    }
}
