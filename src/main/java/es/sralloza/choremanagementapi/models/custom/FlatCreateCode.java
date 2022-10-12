package es.sralloza.choremanagementapi.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import java.time.OffsetDateTime;

@Data
@Accessors(chain = true)
public class FlatCreateCode {
    private String code;
    @JsonProperty("expires_at")
    private OffsetDateTime expiresAt;
}
