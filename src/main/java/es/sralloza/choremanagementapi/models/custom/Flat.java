package es.sralloza.choremanagementapi.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import java.util.UUID;

@Data
@Accessors(chain = true)
public class Flat {
    private String name;
    private FlatSettings settings;
    @JsonProperty("api_key")
    private UUID apiKey;
}
