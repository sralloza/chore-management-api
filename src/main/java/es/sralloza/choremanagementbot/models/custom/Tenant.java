package es.sralloza.choremanagementbot.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.util.List;
import java.util.UUID;

@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class Tenant {
    @JsonProperty("tenant_id")
    Integer tenantId;
    String username;
    @JsonProperty("api_token")
    UUID apiToken;
}
