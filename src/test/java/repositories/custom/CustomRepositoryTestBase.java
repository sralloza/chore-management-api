package repositories.custom;

import es.sralloza.choremanagementbot.models.custom.Chore;

import java.util.List;
import java.util.UUID;

public class CustomRepositoryTestBase {
    protected static final String TYPE_1 = "type1";
    protected static final String TYPE_2 = "type2";
    protected static final String TYPE_3 = "type3";

    protected static final String USERNAME_1 = "username1";
    protected static final String USERNAME_2 = "username2";
    protected static final String USERNAME_3 = "username3";

    protected static final String WEEK_1 = "2022.01";
    protected static final String WEEK_2 = "2022.02";
    protected static final String WEEK_3 = "2022.03";

    protected static final UUID UUID_1 = UUID.fromString("416b19b7-bb29-41fa-9902-b286223c8470");
    protected static final UUID UUID_2 = UUID.fromString("5148b184-c9eb-4079-b2f1-b88f86794010");
    protected static final UUID UUID_3 = UUID.fromString("a513e811-90a5-40d4-a6ec-f78feeef36b1");

    protected Chore buildChore(String week, String type, List<Integer> assigned, boolean done) {
        return new Chore(week, type, assigned, done);
    }
}
