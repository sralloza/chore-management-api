package es.sralloza.choremanagementbot.config;

import com.typesafe.config.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

//@Service
public class ConfigRepository {
//    @Autowired
    private Config config;

    public String getString(String key) {
        return config.getString(key);
    }

    public Boolean getBoolean(String key) {
        return config.getBoolean(key);
    }

    public Long getLong(String key) {
        return config.getLong(key);
    }
}
