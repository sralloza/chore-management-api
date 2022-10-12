package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.custom.SimpleUser;
import es.sralloza.choremanagementapi.models.custom.User;
import es.sralloza.choremanagementapi.models.db.DBUser;
import org.springframework.stereotype.Service;

@Service
public class SimpleUserMapper {
    public SimpleUser build(User user) {
        return new SimpleUser()
            .setUserId(user.getUserId())
            .setUsername(user.getUsername());
    }

    public SimpleUser build(DBUser dbUser) {
        return new SimpleUser()
            .setUserId(dbUser.getUserId())
            .setUsername(dbUser.getUsername());
    }
}
