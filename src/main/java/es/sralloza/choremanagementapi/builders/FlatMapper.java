package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.custom.Flat;
import es.sralloza.choremanagementapi.models.custom.FlatSettings;
import es.sralloza.choremanagementapi.models.db.DBFlat;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.UUID;
import java.util.stream.Collectors;

@Component
public class FlatMapper {
    public Flat build(DBFlat dbFlat) {
        return new Flat()
            .setName(dbFlat.getName())
            .setSettings(new FlatSettings()
            .setAssignmentOrder(Arrays.stream(dbFlat.getAssignmentOrder().split(","))
                .filter(s -> !s.isEmpty())
                .map(Long::parseLong).collect(Collectors.toList()))
                .setRotationSign(dbFlat.getRotationSign())
            )
            .setApiKey(UUID.fromString(dbFlat.getApiKey()));
    }
}
