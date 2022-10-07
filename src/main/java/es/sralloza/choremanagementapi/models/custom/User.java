package es.sralloza.choremanagementapi.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.util.UUID;

@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @JsonProperty("user_id")
    Long userId;
    String username;
    @JsonProperty("api_token")
    UUID apiToken;
}
