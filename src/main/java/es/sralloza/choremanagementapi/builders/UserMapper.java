package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.custom.User;
import es.sralloza.choremanagementapi.models.db.DBUser;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class UserMapper {
    public User build(DBUser dbUser) {
        return new User()
            .setUserId(dbUser.getUserId())
            .setUsername(dbUser.getUsername())
            .setApiKey(UUID.fromString(dbUser.getApiToken()))
            .setFlatName(dbUser.getFlatName());
    }

    public DBUser build(User user) {
        return new DBUser()
            .setUserId(user.getUserId())
            .setUsername(user.getUsername())
            .setApiToken(user.getApiKey().toString())
            .setFlatName(user.getFlatName());
    }
}